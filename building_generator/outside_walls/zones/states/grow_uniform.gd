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
enum {GROW, CHECK, COMPLETE}
var state = CHECK
func run(obj):
	var tris = obj.tris
	if state == CHECK:
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
					
		if ok:
			state = GROW
		else:
			state = COMPLETE
	elif state == GROW:
		var poly = []
		var max_length = 0.0
		for k in obj.shape.segments:
			if max_length < k.length():
				max_length = k.length()
		for k in obj.shape.segments:
			poly.push_back(k * (max_length + 0.1) / max_length)
		obj.shape.segments = poly
		obj.update_shape()
		state = CHECK
	elif state == COMPLETE:
		return "next"

func init(obj):
	state = CHECK
