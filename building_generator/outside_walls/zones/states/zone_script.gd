extends Node
class_name ZoneState

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func collides_walls(obj: Node2D, shape: Shape2D, xform: Transform2D) -> bool:
	for h in obj.outside_walls_segments:
		if shape.collide(xform, h, obj.outside_walls_xform):
			return true
	return false

func create_convex_shapes(shape: Shape2D) -> Array:
	var shapes = []
	var tris = Geometry.triangulate_polygon(shape.segments)
	for h in range(0, tris.size(), 3):
		var poly = []
		for l in range(3):
			poly.push_back(shape.segments[tris[h + l]])
		var convex_shape = ConvexPolygonShape2D.new()
		convex_shape.points = poly
		shapes.push_back(convex_shape)
	return shapes
func check_shape_collision(obj: Node2D) -> bool:
	var ok = true
	for h in obj.outside_walls_segments:
		if obj.collide(h, obj.outside_walls_xform):
			ok = false
		else:
			for z in get_tree().get_nodes_in_group("zones"):
				if z.shape == obj.shape:
					continue
				if !obj.collide(z.circle_shape, z.global_transform):
					continue
				else:
					for k in z.convex_shapes:
						if obj.collide(k, z.global_transform):
							ok = false
							break

	return !ok

func collide_shape(obj: Node2D, shape: Shape2D, xform: Transform2D) -> bool:
	for k in get_tree().get_nodes_in_group("zones"):
		if obj == k:
			continue
		for s in k.convex_shapes:
			if shape.collide(xform, s, k.global_transform):
				return true
	return false
func check_convex_shape(obj: Node2D, shape: Shape2D, xform: Transform2D) -> bool:
	if collides_walls(obj, shape, xform):
		return false
	elif collide_shape(obj, shape, xform):
		return false
	return true
func check_concave_shape(obj: Node2D, shape: Shape2D, xform: Transform2D) -> bool:
	var shapes = create_convex_shapes(shape)
	for k in shapes:
		if !check_convex_shape(obj, k, xform):
			return false
	return true
func check_polygon(obj: Node2D, poly: PoolVector2Array, xform: Transform2D) -> bool:
	var shape = ConcavePolygonShape2D.new()
	shape.segments = poly
	return check_concave_shape(obj, shape, xform)
func check_segment(obj: Node2D, poly: PoolVector2Array, xform: Transform2D) -> bool:
	var shape = SegmentShape2D.new()
	shape.a = poly[0]
	shape.b = poly[1]
	return check_convex_shape(obj, shape, xform)
func check_polygon_grid(obj: Node2D, poly: PoolVector2Array, xform: Transform2D) -> bool:
	var ok:bool = true
	var step:float = min(obj.stepx, obj.stepy) / 4.0
	for h in poly.size():
		var p1 = xform.xform(poly[h])
		var p2 = xform.xform(poly[(h + 1) % poly.size()])
		var vec = (p2 - p1).normalized()
		var p = p1
		while p.distance_to(p2) > step:
			if obj.grid.getpixel(p) != 0 && obj.grid.getpixel(p) != obj.area_id:
				ok = false
				break
			p += vec * step
		if !ok:
			break
	return ok
func check_segment_grid(obj: Node2D, poly: PoolVector2Array, xform: Transform2D) -> bool:
	var ok:bool = true
	var p1 = xform.xform(poly[0])
	var p2 = xform.xform(poly[1])
	var vec = (p2 - p1).normalized()
	var step:float = min(obj.stepx, obj.stepy) / 4.0
	var p = p1
	while p.distance_to(p2) > step:
		if obj.grid.getpixel(p) != 0 && obj.grid.getpixel(p) != obj.area_id:
			ok = false
			break
		p += vec * step
	return ok
func check_segment_grid_same_area_or_walls(obj: Node2D, poly: PoolVector2Array, xform: Transform2D) -> bool:
	var ok:bool = true
	var p1 = xform.xform(poly[0])
	var p2 = xform.xform(poly[1])
	var vec = (p2 - p1).normalized()
	var step:float = min(obj.stepx, obj.stepy) / 4.0
	var p = p1
	while p.distance_to(p2) > step:
		if !obj.grid.getpixel(p) in [0, 1, obj.area_id]:
			ok = false
			break
		p += vec * step
	return ok
