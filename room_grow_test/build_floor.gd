extends Node

signal spawn_point
signal windows_ready
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(Array, PackedScene) var windows = []
export(Array, PackedScene) var rooms = []

var window_spacing = 1.2
var max_rooms = 100
var min_rooms = 30
var max_time = 10.0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var rnd: RandomNumberGenerator
var polygon: PoolVector2Array
var tris: PoolIntArray
var rect: Rect2
var windows_pos = []
var grid_x = 32
var grid_y = 32
var grid_n = 8

func init(poly: PoolVector2Array, xform: Transform2D):
	rnd = RandomNumberGenerator.new()
	var points = PoolVector2Array()
	for k in poly:
		points.push_back(xform.xform(k))
	polygon = points
	tris = Geometry.triangulate_polygon(polygon)
	rect = Rect2()
	for k in polygon:
		rect = rect.expand(k)
	for r in get_children():
		if r.has_method("init"):
			r.init(poly, rnd)

# Called every frame. 'delta' is the elapsed time since the previous frame.
var state = 0
func build_windows():
	for h in range(polygon.size()):
		var p1 = polygon[h]
		var p2 = polygon[(h + 1) % polygon.size()]
		var dir = (p2 - p1).normalized()
		var l = (p2 - p1).length()
		var window_count = int(l / window_spacing)
		var offset = l - window_count * window_spacing
		var p = p1 + dir * (offset / 2.0)
		var wt = windows[rnd.randi() % windows.size()]
		for m in range(window_count):
			var w = wt.instance()
			p += dir * window_spacing
			$windows.add_child(w)
			var tw = Transform2D(dir.angle(), p)
			windows_pos.push_back(tw)
			w.transform = tw
			w.add_to_group("windows")
			print($windows.get_child_count())
func spawn_room(point: Vector2):
	var room = rooms[rnd.randi() % rooms.size()]
	var r = room.instance()
	$rooms.add_child(r)
	var tw = Transform2D(0, point)
	r.transform = tw
	r.add_to_group("rooms")
	r.hide()
var build_time = 0.0
func _process(delta):
	if !polygon:
		return
	if state == 0:
		build_windows()
		state = state + 1
		emit_signal("windows_ready")
	elif state == 1:
		var point: Vector2
		for k in $spawn_gen.get_children():
			var p = k.get_next_point()
			if p == null:
				continue
			point = p
			break
		if $spawn_check.check(point):
			if $point_grid.add_point(point):
				emit_signal("spawn_point", point)
				spawn_room(point)
		var current_room_count = get_tree().get_nodes_in_group("rooms").size()
		if current_room_count > max_rooms:
			state = state + 1
		else:
			build_time += delta
			if build_time > max_time && current_room_count > min_rooms:
				state = state + 1
			elif build_time > max_time * 3:
				state = state + 1
	elif state == 2:
		$grow_rooms.grow_rooms()
