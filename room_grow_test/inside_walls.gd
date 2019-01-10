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
var polygon
var rect: Rect2
var tris: PoolIntArray
func init(poly, rnd):
	polygon = poly
	rect = Rect2()
	for p in polygon:
		rect = rect.expand(p)
	tris = Geometry.triangulate_polygon(polygon)
func check(point: Vector2) -> bool:
	if !polygon:
		return true
	if !rect.has_point(point):
		return false
	var ok = false
	for t in range(0, tris.size(), 3):
		var p1 = polygon[tris[t]]
		var p2 = polygon[tris[t + 1]]
		var p3 = polygon[tris[t + 2]]
		if Geometry.point_is_inside_triangle(point, p1, p2, p3):
			ok = true
			break
	return ok