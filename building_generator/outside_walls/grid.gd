extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
var aabb: Rect2
var stepx: float
var stepy: float
var precision: int
var grid
func _draw():
	draw_rect(aabb, Color(1, 1, 1, 0.5), true)
	for h in range(grid.grid.size()):
		var d = grid.grid[h]
		if d != 0:
			var py = int(h / precision)
			var px = h % precision
			var x = px * stepx + aabb.position.x
			var y = py * stepy + aabb.position.y
			var grect = Rect2(x, y, stepx, stepy)
#			print("dawg ", grect.size)
			if d == 1:
				draw_rect(grect, Color(0, 0, 0, 0.5), true)
			elif d != 0:
				draw_rect(grect, Color((float(d) + 10.0)/ 255.0, 0.3, 0, 0.5), true)
