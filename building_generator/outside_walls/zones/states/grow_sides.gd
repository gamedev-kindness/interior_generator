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
export var current_dim = -1
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
			print("complete")
	elif state == GROW:
		var poly = []
		var max_length = 0.0
		for k in obj.shape.segments:
			if max_length < k.length():
				max_length = k.length()
		if current_dim == 0:
			for k in obj.shape.segments:
				var vec = k
				if k.x < -0.01:
					vec = Vector2(k.x * (max_length + 0.1) / max_length, k.y)
				poly.push_back(vec)
		elif current_dim == 1:
			for k in obj.shape.segments:
				var vec = k
				if k.x > 0.01:
					vec = Vector2(k.x * (max_length + 0.1) / max_length, k.y)
				poly.push_back(vec)
		elif current_dim == 2:
			for k in obj.shape.segments:
				var vec = k
				if k.y < -0.01:
					vec = Vector2(k.x, k.y * (max_length + 0.1) / max_length)
				poly.push_back(vec)
		elif current_dim == 3:
			for k in obj.shape.segments:
				var vec = k
				if k.y > 0.01:
					vec = Vector2(k.x, k.y * (max_length + 0.1) / max_length)
				poly.push_back(vec)
		obj.shape.segments = poly
		obj.update_shape()
		state = CHECK
	elif state == COMPLETE:
		state = CHECK
		return "next"
func init(obj):
	state = CHECK
