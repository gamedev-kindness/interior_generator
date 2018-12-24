extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var rseed = 863210
const window_space = 4.5
const window_width = 2.0
const max_zone_count = 40
onready var rnd = RandomNumberGenerator.new()
func create_room(w):
	var area = Area2D.new()
func _ready():
	rnd.seed = rseed
#	$Navigation2D.navpoly_add(nav, transform)

# Called every frame. 'delta' is the elapsed time since the previous frame.
enum  {
	STATE_INIT,
	STATE_FRONT_DOOR,
	STATE_WINDOW,
	STATE_ZONE,
	STATE_ROOM,
	STATE_BUILD,
}
var state = STATE_INIT
var rooms = []
var outline

var room_types = [
	{
		"name": "kitchen",
		"probability": 0.1,
		"window": true,
		"min_size": 2.0,
		"min_area": 6.0,
		"max_area": 20.0,
		"grow_probability": 0.1,
		"private": false,
		"min_count": 2
	},
	{
		"name": "toilet",
		"probability": 0.2,
		"window": false,
		"min_size": 2.0,
		"min_area": 6.0,
		"max_area": 16.0,
		"grow_probability": 0.1,
		"private": true,
		"min_count": 2
	},
	{
		"name": "common",
		"probability": 0.3,
		"window": true,
		"min_size": 2.0,
		"min_area": 6.0,
		"max_area": 30.0,
		"grow_probability": 0.9,
		"private": false,
		"min_count": 0
	},
	{
		"name": "bedroom",
		"probability": 0.6,
		"window": true,
		"min_size": 2.0,
		"min_area": 12.0,
		"max_area": 20.0,
		"grow_probability": 0.5,
		"private": true,
		"min_count": 1
	},
]
var aabb = Rect2()
var budget = 0.0
func pick_room_type():
	var prnd = rnd.randf()
	for k in room_types:
		if prnd <= k.probability:
			return k
	return null
func pick_zone_type():
	var prnd = rnd.randf()
	for k in $zones.get_children():
		if prnd <= k.probability:
			return k
	return null

var avoid_list = []

func _process(delta):
	if state == STATE_INIT:
		var nav = NavigationPolygonInstance.new()
		var navp = NavigationPolygon.new()
		outline = $outside_walls/CollisionPolygon2D.polygon
		navp.add_outline(outline)
		navp.make_polygons_from_outlines()
		nav.navpoly = navp
		add_child(nav)
		$Navigation2D.navpoly_add(navp, transform)
		for k in outline:
			aabb = aabb.expand(k)
		budget = aabb.get_area() / 2.0
		state = STATE_FRONT_DOOR
	elif state == STATE_FRONT_DOOR:
		var door_seg_start = rnd.randi() % (outline.size() - 1)
		var p1 = outline[door_seg_start]
		var p2 = outline[door_seg_start + 1]
		var seg_n = (p2 - p1)
		var door_pos = (p1 + p2) / 2.0
		var door = load("res://building_generator/rooms/door.tscn").instance()
		add_child(door)
		door.position = door_pos
		door.look_at(door_pos + seg_n)
		avoid_list.push_back(door_pos)
		state = STATE_WINDOW
	elif state == STATE_WINDOW:
		for k in range(outline.size()):
			var p1 = outline[k]
			var p2 = outline[(k + 1) % outline.size()]
			var seg_n = (p2 - p1)
			var seg_length = (p2 - p1).length()
			var w_v = (p2 - p1).normalized()
			var w_b = fmod(seg_length, window_space) / 2.0
			var n_seg = int(seg_length / window_space)
			var tp = w_b + (window_space - window_width)/ 2.0
			for h in range(n_seg):
				var win_pos = p1 + w_v * (tp + window_width / 2.0)
				var ok = true
				for p in avoid_list:
					if p.distance_to(win_pos) < 2.1:
						ok = false
				if !ok:
					continue
				var window = load("res://building_generator/rooms/window.tscn").instance()
				add_child(window)
				window.position = win_pos
				window.look_at(win_pos + seg_n)
				window.add_to_group("windows")
				window.seg_n = seg_n
				window.segment = k
				tp += window_space
		state = STATE_ZONE
	elif state == STATE_ZONE:
		var total_area = 0.0
		for k in get_tree().get_nodes_in_group("zones"):
			total_area += k.get_area()
		while budget > total_area && get_tree().get_nodes_in_group("zones").size() < max_zone_count:
			var zone_type = pick_zone_type()
			var room_pos = Vector2(0, 0)
			var room_look = Vector2(1, 0)
			var room_valid = false
			var w
			if zone_type.window:
				var windows = get_tree().get_nodes_in_group("windows")
				w = windows[randi() % windows.size()]
				if w.room == null:
					var n = -w.seg_n.tangent().normalized() * 2.0
					room_pos = w.position + n
					room_look = w.position + n * 2.0
					room_valid = true
			else:
				room_pos = Vector2(rnd.randf() * aabb.size.x - aabb.position.x, rnd.randf() * aabb.size.y - aabb.position.y)
				room_look = room_pos + Vector2(1, 0)
				room_valid = true
			var room = zone_type.data.instance()
			room.add_to_group("zones")
			add_child(room)
			room.position = room_pos
			room.look_at(room_look)
			room.outside_walls = $outside_walls
			room.max_area = zone_type.max_area
			room.rnd = rnd
			room.grow_probability = zone_type.grow_probability
			room.min_area = zone_type.min_area
			if room.room_is_valid() && room.get_area() < budget:
				room_valid = true
				if w != null:
					w.room = room
					room.window = w
#				budget -= room.get_area()
			else:
				room.queue_free()
	elif state == STATE_BUILD:
		pass
