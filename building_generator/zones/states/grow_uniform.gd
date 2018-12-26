extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
enum {GROW, CHECK}
var state = CHECK
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func run(obj):
	match(state):
		CHECK:
			if !obj.room_is_valid() || obj.is_anything_collides_me():
				return "grow_uniform"
			else:
				state = GROW
		GROW:
			if obj.rnd.randf() <= obj.grow_probability:
				obj.grow_uniform()
			state = CHECK
