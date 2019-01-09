extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func init(obj: floor_root):
	for w in get_tree().get_nodes_in_group("rooms"):
		w.can_grow = true
	print("grow")
func run(obj: floor_root, delta: float):
	pass
func exit(obj: floor_root):
	for w in get_tree().get_nodes_in_group("rooms"):
		w.can_grow = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
