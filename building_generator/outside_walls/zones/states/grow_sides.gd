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
export var amount = 0.07
var current_dim = 0
var results = [true, true, true, true]
func run(obj):
	var tris = obj.tris
	if state == GROW:
		if obj.rnd.randf() < obj.grow_probability:
			current_dim = obj.rnd.randi() % 4
			print("dim: ", current_dim)
			var poly = []
			var max_length = 0.0
			for k in obj.shape.segments:
				if max_length < k.length():
					max_length = k.length()
			if current_dim == 0:
				for k in obj.shape.segments:
					var vec = k
					if k.x < -0.01:
						vec = Vector2(k.x * (max_length + amount) / max_length, k.y)
					poly.push_back(vec)
			elif current_dim == 1:
				for k in obj.shape.segments:
					var vec = k
					if k.x > 0.01:
						vec = Vector2(k.x * (max_length + amount) / max_length, k.y)
					poly.push_back(vec)
			elif current_dim == 2:
				for k in obj.shape.segments:
					var vec = k
					if k.y < -0.01:
						vec = Vector2(k.x, k.y * (max_length + amount) / max_length)
					poly.push_back(vec)
			elif current_dim == 3:
				for k in obj.shape.segments:
					var vec = k
					if k.y > 0.01:
						vec = Vector2(k.x, k.y * (max_length + amount) / max_length)
					poly.push_back(vec)
			if check_polygon(obj, poly, obj.global_transform):
				obj.shape.segments = poly
				obj.update_shape()
				results[current_dim] = true
			else:
				results[current_dim] = false
				state = COMPLETE
				for h in results:
					if h == true:
						state = GROW
						break						
	elif state == COMPLETE:
		state = GROW
		return "next"
func init(obj):
	state = GROW
	results = [true, true, true, true]
