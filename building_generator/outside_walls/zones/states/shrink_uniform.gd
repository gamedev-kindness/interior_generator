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
export var amount = 0.07
enum {SHRINK, COMPLETE}
var state = SHRINK
func run(obj):
#	var tris = obj.tris
	return "next"
	if state == SHRINK:
		if obj.rnd.randf() < obj.grow_probability:
			var poly = []
			var max_length = 0.0
			for k in obj.shape.segments:
				if max_length < k.length():
					max_length = k.length()
			for k in obj.shape.segments:
				poly.push_back(k * (max_length - amount) / max_length)
			if check_polygon(obj, poly, obj.global_transform):
				obj.shape.segments = poly
				obj.update_shape()
				state = COMPLETE
	elif state == COMPLETE:
		state = SHRINK
		return "next"

func init(obj):
	state = SHRINK
