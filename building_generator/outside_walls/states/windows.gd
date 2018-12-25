extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

const window_width = 0.8
const window_space = 1.2
func run(obj):
	var poly = obj.shape.segments
	for k in range(poly.size()):
		var segment = [poly[k], poly[(k + 1) % poly.size()]]
		var seg_vector = segment[1] - segment[0]
		var seg_length = seg_vector.length()
		var window_count = int(seg_length / window_space)
		var offset = (seg_length - window_space * window_count) / 2.0
		var current_pos = segment[0] + seg_vector.normalized() * (offset + window_space / 2.0)
		for idx in range(window_count):
			var w = load("res://building_generator/outside_walls/windows/window1.tscn").instance()
			obj.add_child(w)
			w.position = current_pos
			w.rotation = seg_vector.angle()
			current_pos += seg_vector.normalized() * window_space
	return "next"
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
