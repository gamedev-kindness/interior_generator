extends Spatial

export var floor_height:float = 2.7
export var window_mesh: Mesh
export var window_spacing: float = 1.2
export var room: PackedScene
onready var poly = $"Viewport/2dpart/poly".polygon
onready var poly_xform = $"Viewport/2dpart/poly".global_transform
onready var walls = $"3dpart/combiner/walls"
onready var combiner = $"3dpart/combiner"
var seeddata = 3233232323
var pv = []
var rpv = []
var grid: PoolIntArray
var rect
var grid_cell_size:int = 4
var grid_x:int = 0
var grid_y:int = 0
onready var rnd = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func inside_walls(rv: Vector2, xform: Transform2D) -> bool:
	var pt = Geometry.triangulate_polygon(rpv)
	var inside = false
	for h in range(0, pt.size(), 3):
		if Geometry.point_is_inside_triangle(xform.xform(rv), rpv[pt[h]], rpv[pt[h + 1]], rpv[pt[h + 2]]):
			inside = true
			break
	return inside

func grid2p(x:int, y:int) -> Vector2:
	return Vector2(float(x * grid_cell_size) + float(grid_cell_size) / 2.0, float(y * grid_cell_size) + float(grid_cell_size) / 2.0) + rect.position

func get_grid(p: Vector2) -> int:
	var r = p - Vector2(float(grid_cell_size) / 2.0, float(grid_cell_size) / 2.0) - rect.position
	var x = int(r.x / grid_cell_size)
	var y = int(r.y / grid_cell_size)
	return grid[y * grid_y + x]

func set_grid(p: Vector2, t: int):
	var r = p - Vector2(float(grid_cell_size) / 2.0, float(grid_cell_size) / 2.0) - rect.position
	var x = int(r.x / grid_cell_size)
	var y = int(r.y / grid_cell_size)
	grid[y * grid_y + x] = t

func distance_to_walls(p: Vector2):
	var mind = rect.size.length()
	for k in range(rpv.size()):
		var p1 = rpv[k]
		var p2 = rpv[(k + 1) % rpv.size()]
		var pd = Geometry.get_closest_point_to_segment_2d(p, p1, p2)
		mind = min(mind, p.distance_to(pd))
	return mind


func get_new_point():
	while true:
		var x = rnd.randi() % grid_x
		var y = rnd.randi() % grid_y
		if grid[y * grid_x + x] == 0:
			var p = Vector2(x * float(grid_cell_size), y * float(grid_cell_size)) + rect.position
			if inside_walls(p, Transform2D()) && distance_to_walls(p) > grid_cell_size * 1.5:
				return p
		else:
			var ok = false
			for k in grid:
				if k == 0:
					ok = true
					break
			if !ok:
				return false
	return null


func _ready():
	rnd.seed = seeddata
	for k in range(poly.size()):
		var p1 = poly[k]
		var p2 = poly[(k + 1) % poly.size()]
		if (p2 - p1).length() >= window_spacing / 2.0:
			var p = p1
			while p.distance_to(p2) >= window_spacing / 2.0:
				pv.push_back(poly_xform.xform(p))
				p += (p2 - p1).normalized() * (window_spacing / 2.0)
		else:
			pv.push_back(poly_xform.xform(poly[k]))
		rpv.push_back(poly_xform.xform(poly[k]))
	walls.polygon = pv
	walls.depth = floor_height
	rect = Rect2()
	for k in rpv:
		rect = rect.expand(k)
	print(rect.size)
	grid_x = int(floor(rect.size.x / grid_cell_size)) + 2
	grid_y = int(floor(rect.size.y / grid_cell_size)) + 2
	print(grid_x, " ", grid_y)
	grid = PoolIntArray()
	grid.resize(grid_x * grid_y)
	for rp in range(grid.size()):
		grid[rp] = 0
	for gh in range(grid_y):
		for gw in range(grid_x):
			if !inside_walls(grid2p(gw, gh), Transform2D()):
				grid[gh * grid_x + gw] = 1
### windows
	var ws = []
	for p in range(rpv.size()):
		var p1 = rpv[p]
		var p2 = rpv[(p + 1) % rpv.size()]
		var l = (p2 - p1).length()
		var d = (p2 - p1).normalized().angle()
		var window_count = int(floor((l - window_spacing / 2.0) / window_spacing))
		if window_count <= 0:
			continue
		var offset = (l - window_count * window_spacing) / 2.0 + window_spacing / 2.0
		var p1t = Vector3(p1.x, floor_height / 2.0, p1.y)
		var p2t = Vector3(p2.x, floor_height / 2.0, p2.y)
		var dir = (p2t - p1t).normalized()
		var pcur = p1t + dir * offset
		for h in range(window_count):
			var window = CSGMesh.new()
			window.mesh = window_mesh
			window.operation = CSGShape.OPERATION_SUBTRACTION
			combiner.add_child(window)
			window.translation = pcur
			window.rotation.y = -d
			pcur += dir * window_spacing
			window.add_to_group("windows")
### window rooms
	var count_room = 2
	for p in get_tree().get_nodes_in_group("windows"):
		var pos = p.transform.xform(Vector3(0, 0, 2))
		var rot = p.rotation
		if get_grid(Vector2(pos.x, pos.z)) != 0:
			continue
		set_grid(Vector2(pos.x, pos.z), count_room)
		var r = room.instance()
		combiner.add_child(r)
		r.translation = pos
		r.rotation = rot
		r.operation = CSGShape.OPERATION_SUBTRACTION
		r.add_to_group("rooms")
		count_room += 1
### random rooms
	var max_rooms = get_tree().get_nodes_in_group("rooms").size()
	for k in grid:
		if k != 1:
			max_rooms += 1
	var room_count = get_tree().get_nodes_in_group("rooms").size()
	print("max_rooms=", max_rooms)
	while room_count < max_rooms:
		var ok = false
		for k in grid:
			if k == 0:
				ok = true
				break
		if !ok:
			break
		var pos = get_new_point()
		if pos == null:
			break
#		if get_grid(Vector2(pos.x, pos.y)) != 0:
#			continue
		if !inside_walls(pos, Transform2D()):
			continue
		print(pos)
		set_grid(Vector2(pos.x, pos.y), count_room)
		var r = room.instance()
		combiner.add_child(r)
		r.translation = Vector3(pos.x, 0, pos.y)
		r.operation = CSGShape.OPERATION_SUBTRACTION
		r.add_to_group("rooms")
		count_room += 1
		room_count = get_tree().get_nodes_in_group("rooms").size()
