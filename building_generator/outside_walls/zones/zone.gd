extends Node2D
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal complete
var shape
var tris
var circle_shape
var convex_shapes = []
var can_run = false
var outside_walls
var outside_walls_obj
var outside_walls_segments
var outside_walls_xform
var rnd
var probability = 0.0
var grow_probability = 0.0
var min_area = 0.0
var max_area = 0.0
var stepx = 0.0
var stepy = 0.0
var grid
var area_id
var complete = false

func report_spawned():
	outside_walls_obj.emit_signal("spawned", self, area_id, 4.0)

func update_shape_grid():
	var step:float = min(stepx, stepy) / 2.0
	for h in range(shape.segments.size()):
		var p1 = global_transform.xform(shape.segments[h])
		var p2 = global_transform.xform(shape.segments[(h + 1) % shape.segments.size()])
		var vec = (p2 - p1).normalized()
		var p = p1
		grid.plot(p, area_id)
		while p.distance_to(p2) > step:
			grid.plot(p, area_id)
			p += vec * step


func update_shape():
	$poly.polygon = shape.segments
	tris = Geometry.triangulate_polygon(shape.segments)
	circle_shape = CircleShape2D.new()
	for k in shape.segments:
		if circle_shape.radius < k.length():
			circle_shape.radius = k.length()
	convex_shapes.clear()
	for r in range(0, tris.size(), 3):
		var t1 = tris[r]
		var t2 = tris[r + 1]
		var t3 = tris[r + 2]
		var seg = [shape.segments[t1], shape.segments[t2], shape.segments[t3]]
		var cshape = ConvexPolygonShape2D.new()
		cshape.points = seg
		convex_shapes.push_back(cshape)

func collide(shape, xform):
	if !circle_shape.collide(global_transform, shape, xform):
		return false
	var ret = false
	for s in convex_shapes:
		if s.collide(global_transform, shape, xform):
			ret = true
			break
	return ret

var state = 0
# Called when the node enters the scene tree for the first time.
func all_done(obj):
	pass
func align_to_grid():
	for h in range(shape.segments.size()):
		var p = global_transform.xform(shape.segments[h])
		if grid.getpixel(p) == area_id:
			var up =  grid.align(p)
			var np = global_transform.xform_inv(up)
			shape.segments[h] = np
	update_shape()
		
func _ready():
	add_to_group("zones")
	if shape == null:
		shape = ConcavePolygonShape2D.new()
		shape.segments = $poly.polygon
		update_shape()
	var states = $states.get_children()
	states[state].init(self)
	connect("complete", self, "all_done")
func _process(delta):
	if !can_run:
		return
	var states = $states.get_children()
	var next = states[state].run(self)
	if next == "next":
		if state < states.size() - 1:
			state += 1
			states[state].init(self)
		else:
			can_run = false
			complete = true
			emit_signal("complete", self)
	elif next == "prev":
		if state > 0:
			state -= 1
			states[state].init(self)
	else:
		for p in range(states.size()):
			if states[p].name == next:
				state = p
				break
