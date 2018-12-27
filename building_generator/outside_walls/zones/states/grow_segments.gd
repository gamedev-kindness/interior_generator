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
var move_offset = 0.05
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
			print("complete")
	elif state == GROW:
		var poly = []
		var segs = obj.shape.segments
		for p in segs:
			poly.push_back(p)
		for p in range(segs.size()):
			var seg = [segs[p], segs[(p + 1) % segs.size()]]
			var seg_vec = seg[1] - seg[0]
			var seg_n = -seg_vec.normalized().tangent()
			seg[0] += seg_n * move_offset
			seg[1] += seg_n * move_offset
			if check_segment(obj, seg, obj.global_transform):
				poly[p] = seg[0]
				poly[(p + 1) % poly.size()] = seg[1]
		obj.shape.segments = poly
		obj.update_shape()
		state = CHECK
	elif state == COMPLETE:
		state = CHECK
		return "next"
func init(obj):
	state = CHECK
