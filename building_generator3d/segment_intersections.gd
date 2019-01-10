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
func check(obj, poly) -> bool:
	var xform = obj.get_trans2d()
	for p in  range(poly.size()):
		var ap1 = xform.xform(poly[p])
		var ap2 = xform.xform(poly[(p + 1) % poly.size()])
		var seg1 = [ap1, ap2]
		for r in get_tree().get_nodes_in_group("rooms"):
			var pxform = r.get_trans2d()
			var ppoly = r.get_polygon()
			for q in range(ppoly.size()):
				var aq1 = pxform.xform(ppoly[q])
				var aq2 = pxform.xform(ppoly[(q + 1) % ppoly.size()])
				var seg2 = [aq1, aq2]
				if Geometry.segment_intersects_segment_2d(seg1[0], seg1[1], seg2[0], seg2[1]) != null:
					return false
			
	return true