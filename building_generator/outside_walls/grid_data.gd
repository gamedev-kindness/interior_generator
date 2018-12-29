extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var grid
var precision = 32
func _ready():
	grid = PoolIntArray()
	grid.resize(precision * precision)
	for h in range(grid.size()):
		grid[h] = 0
func point2grid(obj, p):
	var px = int((p.x - obj.aabb.position.x - 0.5) / obj.stepx)
	var py = int((p.y - obj.aabb.position.y - 0.5) / obj.stepy)
	return py * precision + px
func plot(obj: Node2D, p: Vector2, data: int):
	grid[point2grid(obj, p)] = data
func getpixel(obj: Node2D, p: Vector2):
	return grid[point2grid(obj, p)]
