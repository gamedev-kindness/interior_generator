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
	var ok = true
	for rp in range(poly.size()):
		var p1 = poly[rp]
		var p2 = poly[(rp + 1) % poly.size()]
		var p = p1
		while p.distance_to(p2) > obj.obj.grid_cell_size:
			if obj.obj.distance_to_walls(xform.xform(p)) < 0.8:
				ok = false
				break
			p += (p2 - p1).normalized() * (obj.obj.grid_cell_size / 2.0)
	return ok