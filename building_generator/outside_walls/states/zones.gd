extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func run(obj):
	var shape = obj.shape
	var aabb = obj.aabb
	var rnd = obj.rnd
	var segs = []
	for k in shape.segments:
		segs.push_back(k)
	var pt = Geometry.triangulate_polygon(segs)
	while obj.budget > 4.0 && get_tree().get_nodes_in_group("zones").size() < 100:
		var rv = Vector2(rnd.randf() * aabb.size.x, rnd.randf() * aabb.size.y) + aabb.position
		var inside = false
		for h in range(0, pt.size(), 3):
			if Geometry.point_is_inside_triangle(rv, segs[pt[h]], segs[pt[h + 1]], segs[pt[h + 2]]):
				inside = true
				break
		if inside:
			var zone = load("res://building_generator/outside_walls/zones/zone.tscn").instance()
			obj.add_child(zone)
			zone.position = rv
			zone.outside_walls = obj.shape
			zone.outside_walls_segments = obj.segment_shapes
			zone.outside_walls_xform = obj.global_transform
			zone.rnd = rnd
			obj.budget -= 4.0
			break
	if obj.budget <= 4.0 || get_tree().get_nodes_in_group("zones").size() >= 100:
		return "next"
