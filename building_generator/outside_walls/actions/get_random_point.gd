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

var obj
export var amount_per_frame = 10
func _process(delta):
	var aabb = obj.aabb
	var rnd = obj.rnd
	for runs in range(amount_per_frame):
		var rv = Vector2(rnd.randf() * aabb.size.x, rnd.randf() * aabb.size.y) + aabb.position
		obj.emit_signal("random_point", rv)
