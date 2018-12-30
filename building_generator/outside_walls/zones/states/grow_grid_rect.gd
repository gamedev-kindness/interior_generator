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

var current_dim = 0
func grow_poly(obj, orig_poly):
	var poly = []
	var max_length = 0.0
	var amount = min(obj.stepx, obj.stepy)
	for k in obj.shape.segments:
		if max_length < k.length():
			max_length = k.length()
#	print((max_length + amount) / max_length)
	if current_dim == 0:
		for k in orig_poly:
				var vec = Vector2(k.x * (max_length + amount) / max_length, k.y)
				poly.push_back(vec)
	else:
		for k in orig_poly:
				var vec = Vector2(k.x, k.y * (max_length + amount) / max_length)
				poly.push_back(vec)
	if check_polygon_grid(obj, poly, obj.global_transform):
		return poly
	return null


func run(obj):
	if state == GROW:
		if obj.rnd.randf() < obj.grow_probability:
			var poly = []
			var max_length = 0.0
			var current_dim = obj.rnd.randi() % 2
			var ok1 = false
			var ok2 = false
			for k in obj.shape.segments:
				if max_length < k.length():
					max_length = k.length()
				poly.push_back(k)
			var npoly = grow_poly(obj, poly)
			if npoly != null:
				poly = npoly
				ok1 = true
			current_dim ^= 1
			npoly = grow_poly(obj, poly)
			if npoly != null:
				poly = npoly
				ok2 = true
			if ok1 || ok2:
				obj.shape.segments = poly
				obj.update_shape()
				obj.update_shape_grid()
			else:
				state = COMPLETE
	elif state == COMPLETE:
		state = GROW
		return "next"
func init(obj):
	state = GROW
