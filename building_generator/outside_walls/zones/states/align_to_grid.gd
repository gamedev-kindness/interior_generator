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
enum {GROW, COMPLETE}
var state = GROW

func run(obj):
	return "next"
	if state == GROW:
		if obj.rnd.randf() < obj.grow_probability:
			var poly = []
			var max_length = 0.0
			for k in obj.shape.segments:
				if max_length < k.length():
					max_length = k.length()
			for k in obj.shape.segments:
#				poly.push_back(k * (max_length + min(obj.stepx, obj.stepy)) / max_length)
				var tk = obj.global_transform.xform(k)
				var uptk = Vector2(ceil(k.x / obj.stepx) * obj.stepx, ceil(k.y / obj.stepy) * obj.stepy)
				var ntk = obj.global_transform.xform_inv(uptk)
				poly.push_back(ntk)
#			if check_polygon_grid(obj, poly, obj.global_transform):
			obj.shape.segments = poly
			obj.update_shape()
#			obj.update_shape_grid()
#			else:
			state = COMPLETE
	elif state == COMPLETE:
		return
func init(obj):
	state = GROW
