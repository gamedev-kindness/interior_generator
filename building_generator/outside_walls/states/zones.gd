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
	while obj.budget > 4.0:
		var probability = 0.0
		var grow_probability = 0.0
		var min_area = 0.0
		var max_area = 0.0
		var window = false
		var private = false
		var psel = rnd.randf()
		for h in obj.zone_types:
			if psel < h.probability:
				probability = h.probability
				grow_probability = h.grow_probability
				min_area = h.min_area
				max_area = h.max_area
				window = h.window
				private = h.private
				break
		if !window:
			print("not window")
			var rv = Vector2(rnd.randf() * aabb.size.x, rnd.randf() * aabb.size.y) + aabb.position
			if obj.grid.getpixel(rv) == 0:
				var inside = false
				for h in range(0, pt.size(), 3):
					if Geometry.point_is_inside_triangle(rv, segs[pt[h]], segs[pt[h + 1]], segs[pt[h + 2]]):
						inside = true
						break
				if inside:
					obj.emit_signal("spawn_zone", rv, obj.global_rotation, probability, grow_probability, min_area, max_area)
					break
		else:
			print("window")
			var windows = get_tree().get_nodes_in_group("windows")
			var w = windows[obj.rnd.randi() % windows.size()]
			var rv = w.global_transform.xform(Vector2(0, 2))
			if obj.grid.getpixel(rv) == 0:
				obj.emit_signal("spawn_zone", rv, w.global_rotation, probability, grow_probability, min_area, max_area)
				break
	if obj.budget <= 4.0 || get_tree().get_nodes_in_group("zones").size() >= 100:
		return "next"
