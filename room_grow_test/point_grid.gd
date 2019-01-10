extends Node

var grid_x = 32
var grid_y = 32
var grid_n = 16
var grid
var rect: Rect2
var min_distance = 4.0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
var polygon
func add_point(p: Vector2) -> bool:
	var tp = p - rect.position
	var gx = int(tp.x * grid_x / rect.size.x)
	var gy = int(tp.y * grid_y / rect.size.y)
	if grid[gy * grid_x + gx].size() < grid_n:
		for sp in grid[gy * grid_x + gx]:
			if sp.distance_to(p) < min_distance:
				return false 
		grid[gy * grid_x + gx].push_back(p)
		return true
	else:
		return false

func init(poly, rnd):
	polygon = poly
	grid = []
	grid.resize(grid_x * grid_y)
	for p in range(grid.size()):
		grid[p] = []
	rect = Rect2()
	for p in polygon:
		rect = rect.expand(p)
