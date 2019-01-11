extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var amount = 0.02
func init(poly, rnd):
	pass
func _ready():
	pass # Replace with function body.

func grow_rooms():
	for k in get_tree().get_nodes_in_group("rooms"):
		var rpoly = k.polygon
		var npoly = []
		for p in rpoly:
			npoly.push_back(p * (1.0 + amount))
		k.polygon = npoly

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
