extends Node2D

var window
var aabb
var max_size = 0.0
var max_area = 0.0
var growth = 0.07
var grow_probability = 0.0
var rnd
var growth_small = growth * 0.1
var shrink = growth * 20.0
var outside_walls
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
enum {
	STATE_INIT,
	STATE_GROW_UNIFORM,
	STATE_SHRINK_UNIFORM,
	STATE_GROW_RECT,
	STATE_GROW,
	STATE_COMPLETE
}
var state = STATE_INIT
func check_shape(points):
	var space = get_world_2d().get_direct_space_state()
	var shape = Physics2DShapeQueryParameters.new()
	var shape_data = ConcavePolygonShape2D.new()
	shape_data.segments = points
	shape.set_shape(shape_data)
	shape.collision_layer = 1
	shape.collide_with_areas = true
	shape.transform = global_transform
	shape.margin = 0.2
	var result = space.intersect_shape(shape, 32)
	var ret = true
	for k in result:
		if k.collider != outside_walls:
			ret = false
	return ret
func room_is_valid():
	var space = get_world_2d().get_direct_space_state()
	var shape = Physics2DShapeQueryParameters.new()
	var shape_data = ConcavePolygonShape2D.new()
	var shape_points = []
	if aabb.get_area() > max_area:
		return false
	for k in get_points():
		shape_points.push_back(k.normalized() * (k.length() + 0.25))
	shape_data.segments = shape_points
	shape.set_shape(shape_data)
	shape.collision_layer = 1
	shape.collide_with_areas = true
	shape.transform = global_transform
	shape.margin = 0.2
	var result = space.intersect_shape(shape, 32)
	var ret = true
	for k in result:
		if k.collider != outside_walls:
			ret = false
	if !ret:
		return false
	for p in get_points():
		p = global_transform.xform(p)
		result = space.intersect_point(p, 32, [], 0xffffffff, true, true)
		ret = false
		print(p, result)
		for k in result:
			print(k.collider)
			if k.collider == outside_walls:
				ret = true
		if !ret:
			break
	return ret

func get_points():
	return $Area2D/CollisionPolygon2D.polygon
func can_grow():
	var overlapping = $Area2D.get_overlapping_areas()
	if overlapping.size() == 0:
		return true
	return false
var prev_points = []
func grow_uniform():
	prev_points.clear()
	var new_points = []
	for k in get_points():
		prev_points.push_back(k)
		new_points.push_back(k * (1.0 + growth))
	var ret = check_shape(new_points)
	if ret:
		$Area2D/CollisionPolygon2D.polygon = new_points
		if !room_is_valid():
			$Area2D/CollisionPolygon2D.polygon = prev_points
			return false
	return ret
func shrink_uniform():
	var new_points = []
	for k in get_points():
		prev_points.push_back(k)
		new_points.push_back(k * (1.0 - shrink))
	var ret = check_shape(new_points)
	if ret:
		$Area2D/CollisionPolygon2D.polygon = new_points
		return room_is_valid()
	return ret
func grow_up():
	pass
func grow_down():
	pass
func grow_left():
	pass
func grow_right():
	pass
func grow():
	return room_is_valid()
func grow_rect():
	return room_is_valid()
func get_area():
	return aabb.get_area()
func _ready():
	aabb = Rect2()
	for k in get_points():
		aabb = aabb.expand(k)
	add_to_group("rooms")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	aabb = Rect2()
	for k in get_points():
		aabb = aabb.expand(k)
	var ov = $Area2D.get_overlapping_areas()
	match(state):
		STATE_INIT:
			var ok = true
			if ov.size() > 0:
				for h in ov:
					if h != outside_walls:
						ok = false
				if ok:
					state = STATE_GROW_UNIFORM
				else:
					queue_free()
		STATE_GROW_UNIFORM:
			if rnd.randf() <= grow_probability:
				if !grow_uniform():
					state = STATE_SHRINK_UNIFORM
		STATE_SHRINK_UNIFORM:
			if rnd.randf() <= grow_probability:
				if shrink_uniform():
					state = STATE_GROW_RECT
		STATE_GROW_RECT:
			if rnd.randf() <= grow_probability:
				if !grow_rect():
					state = STATE_GROW
		STATE_GROW:
			if rnd.randf() <= grow_probability:
				if !grow():
					state = STATE_COMPLETE
		STATE_COMPLETE:
			pass
	
