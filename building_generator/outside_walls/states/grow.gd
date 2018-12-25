extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func run(obj):
	for k in get_tree().get_nodes_in_group("zones"):
		k.can_run = true
	return "next"
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
