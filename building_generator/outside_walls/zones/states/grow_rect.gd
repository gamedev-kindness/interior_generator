extends ZoneState

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
enum {GROW, SHRINK_X, CHECK, COMPLETE}
var state = CHECK
export var current_dim = -1
var shrink_count = 0
var grow_count = 0
func run(obj):
	var tris = obj.tris
	if state == CHECK:
		var ok = !check_shape_collision(obj)
		if ok:
			state = GROW
		else:
			state = COMPLETE
	elif state == GROW:
		if obj.rnd.randf() < obj.grow_probability:
			grow_count += 1
			var poly = []
			var max_length = 0.0
			for k in obj.shape.segments:
				if max_length < k.length():
					max_length = k.length()
			if current_dim == 0:
				for k in obj.shape.segments:
						var vec = Vector2(k.x * (max_length + 0.1) / max_length, k.y)
						poly.push_back(vec)
			else:
				for k in obj.shape.segments:
						var vec = Vector2(k.x, k.y * (max_length + 0.1) / max_length)
						poly.push_back(vec)
			obj.shape.segments = poly
			obj.update_shape()
			state = CHECK
	elif state == COMPLETE:
		return "next"
func init(obj):
	state = 0
	shrink_count = 0
	grow_count = 0
