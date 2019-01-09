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
func run(obj: floor_root, delta):
### windows
	var ws = []
	var rpv = obj.rpv
	for p in range(rpv.size()):
		var p1 = rpv[p]
		var p2 = rpv[(p + 1) % rpv.size()]
		var l = (p2 - p1).length()
		var d = (p2 - p1).normalized().angle()
		var window_count = int(floor((l - obj.window_spacing / 2.0) / obj.window_spacing))
		if window_count <= 0:
			continue
		var offset = (l - window_count * obj.window_spacing) / 2.0 + obj.window_spacing / 2.0
		var p1t = Vector3(p1.x, obj.floor_height / 2.0, p1.y)
		var p2t = Vector3(p2.x, obj.floor_height / 2.0, p2.y)
		var dir = (p2t - p1t).normalized()
		var pcur = p1t + dir * offset
		for h in range(window_count):
			var window = CSGMesh.new()
			window.mesh = obj.window_mesh
			window.operation = CSGShape.OPERATION_SUBTRACTION
			obj.combiner.add_child(window)
			window.translation = pcur
			window.rotation.y = -d
			pcur += dir * obj.window_spacing
			window.add_to_group("windows")
	return "next"
