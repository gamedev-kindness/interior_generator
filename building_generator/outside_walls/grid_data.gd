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
	grid.resize((precision + 4) * (precision + 4))
	for h in range(grid.size()):
		grid[h] = 0
func point2grid(p):
	var px = int((p.x - walls.aabb.position.x) / walls.stepx)
	var py = int((p.y - walls.aabb.position.y) / walls.stepy)
	return py * precision + px
func align(p, xp, yp):
	var px = int((p.x - walls.aabb.position.x) / walls.stepx + 0.5)
	var py = int((p.y - walls.aabb.position.y) / walls.stepy + 0.5)
	if xp:
		px += 1.0
#	else:
#		px = ceil(px)
	if yp:
		py += 1.0
#	else:
#		py = ceil(py)

	return Vector2(float(px) * walls.stepx + walls.aabb.position.x, float(py) * walls.stepy + walls.aabb.position.y)
func plot(p: Vector2, data: int):
	grid[point2grid(p)] = data
func getpixel(p: Vector2):
	return grid[point2grid(p)]
