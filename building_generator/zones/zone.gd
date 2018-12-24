extends Node2D

var window
var aabb
var max_size = 0.0
var max_area = 0.0
var min_area = 0.0
var growth = 0.07
var grow_probability = 0.0
var rnd
var growth_small = growth * 0.1
var shrink = growth * 0.5
var outside_walls
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
enum {
	STATE_INIT,
	STATE_GROW_UNIFORM,
	STATE_CHECK1,
	STATE_SHRINK_UNIFORM,
	STATE_CHECK2,
	STATE_GROW_RECT,
	STATE_GROW_RECT_X,
	STATE_GROW_RECT_Y,
	STATE_CHECK3,
	STATE_SHRINK_UNIFORM2,
	STATE_CHECK4,
	STATE_GROW,
	STATE_CHECK5,
	STATE_SHRINK_UNIFORM3,
	STATE_CHECK6,
	STATE_COMPLETE,
	STATE_DONE
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
		for k in result:
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
	$Area2D/CollisionPolygon2D.polygon = new_points
func shrink_uniform():
	var new_points = []
	for k in get_points():
		new_points.push_back(k * (1.0 - shrink))
	$Area2D/CollisionPolygon2D.polygon = new_points
func grow_up():
	pass
func grow_down():
	pass
func grow_left():
	pass
func grow_right():
	pass
func grow():
	var points = get_points()
	var p = rnd.randi() % points.size()
	points[p] *= (1.0 + growth_small)
	$Area2D/CollisionPolygon2D.polygon = points
func grow_rect(t):
	var new_points = []
	if t == 0:
		for k in get_points():
				new_points.push_back(Vector2(k.x * (1.0 + growth_small), k.y))
	else:
		for k in get_points():
				new_points.push_back(Vector2(k.x, k.y * (1.0 + growth_small)))
	var ret = check_shape(new_points)
	if ret:
		$Area2D/CollisionPolygon2D.polygon = new_points
	return room_is_valid()
func get_area():
	return aabb.get_area()
func _ready():
	aabb = Rect2()
	for k in get_points():
		aabb = aabb.expand(k)
	add_to_group("zones")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	aabb = Rect2()
	for k in get_points():
		aabb = aabb.expand(k)
	var ov = $Area2D.get_overlapping_areas()
	var rect_dir = 0
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
				grow_uniform()
				state = STATE_CHECK1
		STATE_CHECK1:
			if room_is_valid():
				state = STATE_GROW_UNIFORM
			else:
				state = STATE_SHRINK_UNIFORM
		STATE_SHRINK_UNIFORM:
			shrink_uniform()
			state = STATE_CHECK2
		STATE_CHECK2:
			if room_is_valid():
				state = STATE_GROW_RECT
			else:
				state = STATE_SHRINK_UNIFORM
		STATE_GROW_RECT:
			state = STATE_GROW_RECT_X
			rect_dir = 0
#			state = STATE_GROW_RECT_Y
#				rect_dir = 1
		STATE_GROW_RECT_X:
			if rnd.randf() <= grow_probability:
				grow_rect(0)
				state = STATE_CHECK3
		STATE_GROW_RECT_Y:
			if rnd.randf() <= grow_probability:
				grow_rect(1)
				state = STATE_CHECK3
				print("grow_rect_y")
		STATE_CHECK3:
			if room_is_valid():
				if rect_dir in [0, 3]:
					state = STATE_GROW_RECT_X
				elif rect_dir == [1, 2]:
					state = STATE_GROW_RECT_Y
			else:
				if rect_dir in [0, 1]:
					state = STATE_SHRINK_UNIFORM2
				else:
					state = STATE_CHECK4
		STATE_SHRINK_UNIFORM2:
			shrink_uniform()
			state = STATE_CHECK4
		STATE_CHECK4:
			if room_is_valid():
				if rect_dir == 0:
					state = STATE_GROW_RECT_Y
					rect_dir = 2
				if rect_dir == 1:
					state = STATE_GROW_RECT_X
					rect_dir = 3
				else:
					state = STATE_GROW
			else:
				state = STATE_SHRINK_UNIFORM2
		STATE_GROW:
			if rnd.randf() <= grow_probability:
				grow()
				state = STATE_CHECK5
		STATE_CHECK5:
			if room_is_valid():
				state = STATE_GROW
			else:
				state = STATE_SHRINK_UNIFORM3
		STATE_SHRINK_UNIFORM3:
			shrink_uniform()
			state = STATE_CHECK6
		STATE_CHECK6:
			if room_is_valid():
				state = STATE_COMPLETE
			else:
				state = STATE_SHRINK_UNIFORM3
		STATE_COMPLETE:
			if get_area() < min_area:
				queue_free()
			if !room_is_valid():
				state = STATE_SHRINK_UNIFORM3
			else:
				state = STATE_DONE
			print("complete")
	
