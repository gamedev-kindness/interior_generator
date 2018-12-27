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
enum {GROW, CHECK, COMPLETE}
var state = CHECK
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
