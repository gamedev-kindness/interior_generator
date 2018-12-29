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
export var amount = 0.07
func grow_poly(obj, orig_poly):
	var poly = []
	var max_length = 0.0
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
	if check_polygon(obj, poly, obj.global_transform):
		return poly
	return null
	
func run(obj):
	var tris = obj.tris
	if state == GROW:
		if obj.rnd.randf() < obj.grow_probability:
			current_dim = randi() % 2
			var poly = []
			for k in obj.shape.segments:
				poly.push_back(k)
			var dim0 = true
			var dim1 = true
			var npoly = grow_poly(obj, poly)
			if npoly == null:
				dim0 = false
			else:
				poly = npoly
			current_dim ^= 1
			npoly = grow_poly(obj, poly)
			if npoly == null:
				dim1 = false
			else:
				poly = npoly
			if dim0 || dim1:
				obj.shape.segments = poly
				obj.update_shape()
			else:
				state = COMPLETE
	elif state == COMPLETE:
		state = GROW
		return "next"
func init(obj):
	state = GROW
