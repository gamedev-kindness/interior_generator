extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var connected = false
var obj
func _ready():
	pass # Replace with function body.
var segments = []
func check_point(rv):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !connected:
		connected = true
		obj.connect("random_point_inside", self, "check_point")
		for h in range(obj.shape.segments.size()):
			segments.push_back([obj.shape.segments[h], obj.shape.segments[(h + 1) % obj.shape.segments.size()]])
