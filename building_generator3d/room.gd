extends CSGCombiner

var amount = 0.2
var obj: floor_root
var can_grow = false
var room_id = 2
var concave_shapes = []
var min_area = 4.0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func get_polygon():
	return $poly.polygon
func get_trans2d() -> Transform2D:
	var pos = Vector2(translation.x, translation.z)
	var rot = -rotation.y
	return Transform2D(rot, pos)

func build_convex_shapes():
	concave_shapes.clear()
	var poly = $poly.polygon
	var tris = Geometry.triangulate_polygon(poly)
	for h in range(0, tris.size(), 3):
		var shape = ConvexPolygonShape2D.new()
		var p1 = poly[tris[h]]
		var p2 = poly[tris[h + 1]]
		var p3 = poly[tris[h + 2]]
		var points = [p1, p2, p3]
		shape.points = points
		concave_shapes.push_back(shape)

func check_shape(shape: Shape2D, xform: Transform2D) -> bool:
	for h in concave_shapes:
		if shape.collide(xform, h, get_trans2d()):
			return true
	return false

func check_shapes() -> bool:
	for r in get_tree().get_nodes_in_group("rooms"):
		if r == self:
			continue
		for h in concave_shapes:
			if r.check_shape(h, get_trans2d()):
				return true
	return false
var orig_rect = Rect2()
var new_rect = Rect2()

func _ready():
	build_convex_shapes()

#func grow(obj: floor_root):
#	pass
#
#func connect_signals(obj: floor_root):
#	obj.connect("grow"
# Called every frame. 'delta' is the elapsed time since the previous frame.
func check_inside_walls(poly):
	return true
	var ok = true
	var xform = get_trans2d()
	return obj.poly_inside_walls(poly, xform)
#	for rp in range(poly.size()):
#		var p1 = poly[rp]
#		var p2 = poly[(rp + 1) % poly.size()]
#		var p = p1
#		while p.distance_to(p2) > obj.grid_cell_size:
##			if !obj.get_grid(xform.xform(p)) in [0, room_id]:
##				ok = false
##				break
#			if !obj.inside_walls(p, xform):
#				ok = false
#				break
#			p += (p2 - p1).normalized() * (obj.grid_cell_size / 2.0)
#		if !ok:
#			break
##	if obj.walls_intersect_segments(poly, xform):
##		return false
#	return ok
func update_grid(poly):
	var xform = get_trans2d()
	for p in poly:
		if !obj.get_grid(xform.xform(p)) in [1, room_id]:
			obj.set_grid(xform.xform(p), room_id)

func clear_grid():
	var xform = get_trans2d()
	for p in range(obj.grid.size()):
		if obj.grid[p] == room_id:
			obj.grid[p] = 0

var state = 0
var visited_states = []
var growth_states = []
var failed_checks = []

func _process(delta):
	if can_grow && obj != null:
		var poly = $poly.polygon
		var updated = false
		match(state):
			0:
				for pt in poly:
					orig_rect = orig_rect.expand(pt)
			1:
				for k in range(poly.size()):
					poly[k] = poly[k] * (1.0 + amount * 2.0)
				updated = true
			2:
				for k in range(poly.size()):
					if poly[k].x > 0:
						poly[k].x += amount
					elif poly[k].x < 0:
						poly[k].x -= amount
				updated = true
			3:
				for k in range(poly.size()):
					if poly[k].y > 0:
						poly[k].y += amount
					elif poly[k].y < 0:
						poly[k].y -= amount
				updated = true
			4:
				for k in range(poly.size()):
					if poly[k].x > 0:
						poly[k].x += amount
				updated = true
			5:
				for k in range(poly.size()):
					if poly[k].x < 0:
						poly[k].x -= amount
				updated = true
			6:
				for k in range(poly.size()):
					if poly[k].y > 0:
						poly[k].y += amount
				updated = true
			7:
				for k in range(poly.size()):
					if poly[k].y < 0:
						poly[k].y -= amount
				updated = true
			10:
				for pt in poly:
					new_rect = new_rect.expand(pt)
				can_grow = false
				if new_rect.get_area() < min_area:
					clear_grid()
					queue_free()
				else:
					print("room: ", room_id, " finished, ", orig_rect.get_area(), " ", new_rect.get_area(), " states: ", growth_states, " failed checks:", failed_checks)
#		if updated:
#			print("room: ", room_id, " growing, state=", state)
		if updated && run_checks(poly):
			$poly.polygon = poly
			update_grid(poly)
			build_convex_shapes()
			growth_states.push_back(state)
		else:
			state = state + 1
		visited_states.push_back(state)
func run_checks(poly) -> bool:
	for m in $checks.get_children():
		if m.has_method("check"):
			if !m.check(self, poly):
				failed_checks.push_back(m.name)
				return false
	return true
