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
func cell_size():
	return Vector2(rect.size.x / grid_x, rect.size.y / grid_y)
func find_close_points(p: Vector2, r: float) -> PoolVector2Array:
	var tp = p - rect.position
	var gx1 = max(0, int(tp.x / cell_size().x - r))
	var gx2 = min(grid_x - 1, int(tp.x / cell_size().x + r))
	var gy1 = max(0, int(tp.y / cell_size().y - r))
	var gy2 = min(grid_y - 1, int(tp.y / cell_size().y + r))
	var points = []
	for y in range(gy1, gy2 + 1, 1):
		for x in range(gx1, gx2 + 1, 1):
			for pt in grid[y * grid_x + x]:
				if pt.distance_squared_to(p) < r * r:
					points.push_back(pt)
	return PoolVector2Array(points)
func add_point(p: Vector2) -> bool:
	if find_close_points(p, min_distance).size() > 0:
		return false
	var tp = p - rect.position
	var gx = int(tp.x / cell_size().x)
	var gy = int(tp.y / cell_size().y)
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
	min_distance = min(min_distance, min(cell_size().x, cell_size().y))
