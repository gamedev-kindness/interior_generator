extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _draw():
	var p = Rect2(0, 0, 200, 200)
	draw_rect(p, Color(0, 0, 1), true)
