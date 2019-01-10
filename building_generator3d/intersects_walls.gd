extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func check(obj, poly) -> bool:
	var xform = obj.get_trans2d()
	if obj.obj.walls_intersect_segments(poly, xform):
		return false
	return true
