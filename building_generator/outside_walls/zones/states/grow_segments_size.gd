extends ZoneState

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var single = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
var move_offset = 0.2
enum {GROW, COMPLETE}
var state = GROW
func run(obj):
	return "next"
	var tris = obj.tris
	if state == GROW:
			var poly = []
			var segs = obj.shape.segments
			for p in segs:
				poly.push_back(p)
			var bad = true
			for p in range(segs.size()):
				var seg = [segs[p], segs[(p + 1) % segs.size()]]
				var seg_vec = seg[1] - seg[0]
				var seg_dir = seg_vec.normalized()
				#seg[0] += seg_dir * move_offset
				var next = segs[(p + 2) % segs.size()]
				var seg_vec2 = next - seg[1]
				var seg_dir2 = seg_vec2.normalized()
				var angle = seg_dir.angle_to(seg_dir2)
				if abs(angle) < PI / 2.0:
#					seg[1] -= seg_dir * move_offset
					pass
				elif abs(angle) > PI / 2.0 + 0.2 && abs(angle) < 3.0 * PI / 2.0:
					seg[1] += seg_dir * move_offset
				if !obj.outside_walls_obj.inside_walls(seg[0], obj.global_transform):
					continue
				elif !obj.outside_walls_obj.inside_walls(seg[1], obj.global_transform):
					continue
				elif !check_segment(obj, seg, obj.global_transform):
					continue
				elif check_segment_grid_same_area_or_walls(obj, seg, obj.global_transform):
					poly[p] = seg[0]
					poly[(p + 1) % poly.size()] = seg[1]
					bad = false
					if single:
						break
			if !bad:
				obj.shape.segments = poly
				obj.update_shape()
			else:
				state = COMPLETE
	elif state == COMPLETE:
		state = GROW
		return "next"
func init(obj):
	state = GROW
