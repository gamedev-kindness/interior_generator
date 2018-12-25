extends Node2D
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var shape
var tris
var circle_shape
var convex_shapes = []
var can_run = false
var outside_walls
var outside_walls_segments
var outside_walls_xform
var rnd
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
func _ready():
	add_to_group("zones")
	if shape == null:
		shape = ConcavePolygonShape2D.new()
		shape.segments = $poly.polygon
		update_shape()
	var states = $states.get_children()
	states[state].init(self)
func _process(delta):
	if !can_run:
		return
	var states = $states.get_children()
	var next = states[state].run(self)
	if next == "next":
		if state < states.size() - 1:
			state += 1
			states[state].init(self)
	elif next == "prev":
		if state > 0:
			state -= 1
			states[state].init(self)
	else:
		for p in range(states.size()):
			if states[p].name == next:
				state = p
				break
