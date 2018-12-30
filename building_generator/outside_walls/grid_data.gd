extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var grid
var precision = 32
var walls
func _ready():
	grid = PoolIntArray()
	grid.resize((precision + 2) * (precision + 2))
	for h in range(grid.size()):
		grid[h] = 0
func point2grid(p):
	var px = int((p.x - walls.aabb.position.x) / walls.stepx)
	var py = int((p.y - walls.aabb.position.y) / walls.stepy)
	return py * precision + px
func align(p):
	var px = (p.x - walls.aabb.position.x) / walls.stepx
	var py = (p.y - walls.aabb.position.y) / walls.stepy
	if p.x > 0:
		px = ceil(px + 0.5)
	else:
		px = ceil(px)
	if p.y > 0:
		py = ceil(py + 0.5)
	else:
		py = ceil(py)

	return Vector2(float(px) * walls.stepx + walls.aabb.position.x, float(py) * walls.stepy + walls.aabb.position.y)
func plot(p: Vector2, data: int):
	grid[point2grid(p)] = data
func getpixel(p: Vector2):
	return grid[point2grid(p)]
