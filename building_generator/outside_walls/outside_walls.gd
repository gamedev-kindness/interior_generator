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
func _ready():
	shape = ConcavePolygonShape2D.new()
	shape.segments = $poly.polygon
	rnd = RandomNumberGenerator.new()
	rnd.seed = 8643212
	aabb = Rect2()
	for h in shape.segments:
		print(h)
		aabb = aabb.expand(h)
	print(aabb)
	budget = aabb.get_area() / 150.0
	for k in range(shape.segments.size()):
		var segment = [shape.segments[k], shape.segments[(k + 1) % shape.segments.size()]]
		var seg_shape = SegmentShape2D.new()
		seg_shape.a = segment[0]
		seg_shape.b = segment[1]
		segment_shapes.push_back(seg_shape)

var state = 0
func _process(delta):
	var states = $states.get_children()
	var next = states[state].run(self)
	if next == "next":
		if state < states.size() - 1:
			state += 1
	elif next == "prev":
		if state > 0:
			state -= 1
	else:
		for p in range(states.size()):
			if states[p].name == next:
				state = p
				break
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
