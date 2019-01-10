extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
var polygon
var rnd
var point_count = 0
func init(poly, rnd):
	polygon = poly
	self.rnd = rnd
	point_count = 0
var min_dist = 4.0
var max_dist = 16.0
func get_next_point():
	var ws = get_tree().get_nodes_in_group("windows")
	var max_point_count = ws.size() * 4
	var rw = ws[rnd.randi() % ws.size()]
	var p1 = rw.transform.xform(Vector2(0, min_dist + (max_dist - min_dist) * rnd.randf()))
	var p2 = rw.transform.xform(Vector2(0, -min_dist - (max_dist - min_dist) * rnd.randf()))
	if point_count < max_point_count:
		point_count += 1
		if rnd.randf() >= 0.5:
			return p1
		else:
			return p2
	else:
		return null