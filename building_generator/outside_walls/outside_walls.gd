extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var shape
var rnd
var aabb
var budget
var segment_shapes = []
var zone_types = []
var grid
var area_id = 2
var stepx
var stepy
signal random_point
signal random_point_inside
signal spawn_zone
signal spawned
func zone_spawned(obj, zone_id, new_budget):
	print("spawned")
	budget -= 4.0
	print(budget)

func spawn_zone(p, rot, probability, grow_probability, min_area, max_area):
	var zone = load("res://building_generator/outside_walls/zones/zone.tscn").instance()
	zone.probability = probability
	zone.grow_probability = grow_probability
	zone.min_area = min_area
	zone.max_area = max_area
	zone.area_id = area_id
	zone.stepx = stepx
	zone.stepy = stepy
	zone.grid = $grid
	zone.outside_walls = shape
	zone.outside_walls_segments = segment_shapes
	zone.outside_walls_xform = global_transform
	zone.outside_walls_obj = self
	zone.rnd = rnd
	area_id += 1
	add_child(zone)
	zone.global_position = p
	zone.global_rotation = rot

func sort_zone_types(a, b):
	if a.probability < b.probability:
		return true
	return false
func inside_walls(rv: Vector2, xform: Transform2D) -> bool:
	var segs = []
	for k in shape.segments:
		segs.push_back(global_transform.xform(k))
	var pt = Geometry.triangulate_polygon(segs)
	var inside = false
	for h in range(0, pt.size(), 3):
		if Geometry.point_is_inside_triangle(xform.xform(rv), segs[pt[h]], segs[pt[h + 1]], segs[pt[h + 2]]):
			inside = true
			break
	return inside
func _ready():
	shape = ConcavePolygonShape2D.new()
	shape.segments = $poly.polygon
	rnd = RandomNumberGenerator.new()
	rnd.seed = 8643212
	aabb = Rect2()
	for h in shape.segments:
		print(h)
		aabb = aabb.expand(h)
	stepx = aabb.size.x / $grid.precision
	stepy = aabb.size.y / $grid.precision
	$grid_view.aabb = aabb
	$grid_view.stepx = stepx
	$grid_view.stepy = stepy
	grid = $grid
	$grid_view.grid = $grid
	$grid_view.precision = $grid.precision
	$actions/get_random_point.obj = self
	$actions/test_point_inside.obj = self
	$actions/test_point_walls_distance.obj = self
	$grid.walls = self
	
	print(aabb)
	budget = 50.0
	for k in range(shape.segments.size()):
		var segment = [shape.segments[k], shape.segments[(k + 1) % shape.segments.size()]]
		var seg_shape = SegmentShape2D.new()
		seg_shape.a = segment[0]
		seg_shape.b = segment[1]
		segment_shapes.push_back(seg_shape)
	var score = 0.0
	for m in $room_types.get_children():
		score += m.probability
	for m in $room_types.get_children():
		m.probability = m.probability / score
	score = 0.0
	for m in $room_types.get_children():
		score += m.probability
		m.probability = score
		zone_types.push_back(m)
	zone_types.sort_custom(self, "sort_zone_types")
	connect("spawn_zone", self, "spawn_zone")
	connect("spawned", self, "zone_spawned")

var state = 0
var completed = false
func _process(delta):
	var states = $states.get_children()
	var next = states[state].run(self)
	if next == "next":
		if state < states.size() - 1:
			state += 1
		else:
			print("done")
			completed = false
	elif next == "prev":
		if state > 0:
			state -= 1
	else:
		for p in range(states.size()):
			if states[p].name == next:
				state = p
				break
	$grid_view.update()
	if Input.is_action_pressed("ui_up"):
		$Camera2D.position += Vector2(0, -1) * 100.0 * delta
	
	if Input.is_action_pressed("ui_down"):
		$Camera2D.position += Vector2(0, 1) * 100.0 * delta

	if Input.is_action_pressed("ui_left"):
		$Camera2D.position += Vector2(-1, 0) * 100.0 * delta

	if Input.is_action_pressed("ui_right"):
		$Camera2D.position += Vector2(1, 0) * 100.0 * delta
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
