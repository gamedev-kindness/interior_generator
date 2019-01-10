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
var min_distance = 4.0
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
	var ok = true
	for h in range(polygon.size()):
		var p1 = polygon[h]
		var p2 = polygon[(h + 1) % polygon.size()]
		var cp = Geometry.get_closest_point_to_segment_2d(point, p1, p2)
		if point.distance_to(cp) < min_distance:
			ok = false
			print(point.distance_to(cp))
			break
	return ok
