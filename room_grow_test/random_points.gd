extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var polygon
var rnd
var rect: Rect2
func init(poly, rnd):
	polygon = poly
	self.rnd = rnd
	rect = Rect2()
	for p in polygon:
		rect = rect.expand(p)
func get_next_point():
	var point = Vector2(rnd.randf() * rect.size.x, rnd.randf() * rect.size.y) + rect.position
	return point
