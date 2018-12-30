extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func run(obj):
	var segdata = obj.shape.segments
	var segs = []
	print(obj.grid.grid.size())
	for m in range(obj.grid.grid.size()):
		obj.grid.grid[m] = 0
	for h in range(segdata.size()):
		var p1 = segdata[h]
		var p2 = segdata[(h + 1) % segdata.size()]
		segs.push_back([p1, p2])
		print(p1)
		obj.grid.plot(p1, 1)
		var step = min(obj.stepx, obj.stepy)
		var l = (p2 - p1).length()
		var p = p1
		while p.distance_to(p2) > step:
			p = p.linear_interpolate(p2, step / l)
			obj.grid.plot(p, 1)
	return "next"
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
