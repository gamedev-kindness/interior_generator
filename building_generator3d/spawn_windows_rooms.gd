extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func run(obj: floor_root, delta: float):
### window rooms
	for p in get_tree().get_nodes_in_group("windows"):
		var pos = p.transform.xform(Vector3(0, 0, 2))
		pos.y = 0
		var ok = true
		for h in get_tree().get_nodes_in_group("rooms"):
			if pos.distance_to(h.translation) < 4.0:
				ok = false
				break
		if !ok:
			continue
		var rot = p.rotation
		if obj.get_grid(Vector2(pos.x, pos.z)) != 0:
			continue
		obj.set_grid(Vector2(pos.x, pos.z), obj.count_room)
		var r = obj.room.instance()
		obj.combiner.add_child(r)
		r.translation = pos
		r.rotation = rot
		r.operation = CSGShape.OPERATION_SUBTRACTION
		r.add_to_group("rooms")
		r.obj = obj
		r.room_id = obj.count_room
		obj.count_room += 1
	return "next"
