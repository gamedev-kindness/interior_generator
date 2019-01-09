extends CSGCombiner

var amount = 1.6
var obj: floor_root
var can_grow = false
var room_id = 2
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

#func grow(obj: floor_root):
#	pass
#
#func connect_signals(obj: floor_root):
#	obj.connect("grow"
# Called every frame. 'delta' is the elapsed time since the previous frame.
func check_inside_walls(poly):
	var ok = true
	var xform = Transform2D(-rotation.y, Vector2(translation.x, translation.z))
	for rp in range(poly.size()):
		var p1 = poly[rp]
		var p2 = poly[(rp + 1) % poly.size()]
		var p = p1
		while p.distance_to(p2) > obj.grid_cell_size:
			if !obj.get_grid(xform.xform(p)) in [0, room_id]:
				ok = false
				break
			if !obj.inside_walls(p, xform):
				ok = false
				break
			if obj.distance_to_walls(xform.xform(p)) < 0.1:
				ok = false
				break
			p += (p2 - p1).normalized() * (obj.grid_cell_size / 2.0)
		if !ok:
			break
	return ok
func update_grid(poly):
	var xform = Transform2D(-rotation.y, Vector2(translation.x, translation.z))
	for p in poly:
		if !obj.get_grid(xform.xform(p)) in [0, room_id]:
			obj.set_grid(xform.xform(p), room_id)

var state = 0
func _process(delta):
	if can_grow && obj != null:
		var poly = $poly.polygon
		var updated = false
		match(state):
			0:
				for k in range(poly.size()):
					poly[k] = poly[k] * (1.0 + amount)
				updated = true
			1:
				for k in range(poly.size()):
					if poly[k].x > 0:
						poly[k].x += amount
					elif poly[k].x < 0:
						poly[k].x -= amount
				updated = true
			2:
				for k in range(poly.size()):
					if poly[k].y > 0:
						poly[k].y += amount
					elif poly[k].y < 0:
						poly[k].y -= amount
				updated = true
			3:
				for k in range(poly.size()):
					if poly[k].x > 0:
						poly[k].x += amount
				updated = true
			4:
				for k in range(poly.size()):
					if poly[k].x < 0:
						poly[k].x -= amount
				updated = true
			5:
				for k in range(poly.size()):
					if poly[k].y > 0:
						poly[k].y += amount
				updated = true
			6:
				for k in range(poly.size()):
					if poly[k].y < 0:
						poly[k].y -= amount
				updated = true
			10:
				can_grow = false
		if updated && check_inside_walls(poly):
			$poly.polygon = poly
			update_grid(poly)
		else:
			state = state + 1
