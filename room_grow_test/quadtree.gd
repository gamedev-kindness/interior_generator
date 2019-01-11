extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var root
func _ready():
	root = QuadtreeData.new()

func init(poly, rnd):
	var r = Rect2()
	for p in poly:
		r = r.expand(p)
	root.init(r)

func add_polygon(polygon: Dictionary):
	root.add_polygon(polygon)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for r in get_tree().get_nodes_in_group("rooms"):
		var poly = {
			"polygon": r.polygon,
			"room": r
		}
		print("intersect ", root.find_intersections(poly).size())
		root.add_polygon(poly)