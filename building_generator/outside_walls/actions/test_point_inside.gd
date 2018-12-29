extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.

var obj
var started = false
func check_point(rv):
	if obj.inside_walls(rv, obj.global_transform):
		obj.emit_signal("random_point_inside", rv)
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !started:
		started = true
		obj.connect("random_point", self, "check_point")
