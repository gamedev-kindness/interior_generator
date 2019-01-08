extends Spatial

export var floor_height:float = 2.7
export var window_mesh: Mesh
export var window_spacing: float = 1.2
onready var poly = $"Viewport/2dpart/poly".polygon
onready var poly_xform = $"Viewport/2dpart/poly".global_transform
onready var walls = $"3dpart/combiner/walls"
onready var combiner = $"3dpart/combiner"
var pv = []
var rpv = []
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	for k in range(poly.size()):
		var p1 = poly[k]
		var p2 = poly[(k + 1) % poly.size()]
		if (p2 - p1).length() >= window_spacing / 2.0:
			var p = p1
			while p.distance_to(p2) >= window_spacing / 2.0:
				pv.push_back(poly_xform.xform(p))
				p += (p2 - p1).normalized() * (window_spacing / 2.0)
		else:
			pv.push_back(poly_xform.xform(poly[k]))
		rpv.push_back(poly_xform.xform(poly[k]))
	walls.polygon = pv
	walls.depth = floor_height
### windows
	for p in range(rpv.size()):
		var p1 = rpv[p]
		var p2 = rpv[(p + 1) % rpv.size()]
		var l = (p2 - p1).length()
		var d = (p2 - p1).normalized().angle()
		var window_count = int(floor((l - window_spacing / 2.0) / window_spacing))
		if window_count <= 0:
			continue
		var offset = (l - window_count * window_spacing) / 2.0 + window_spacing / 2.0
		var p1t = Vector3(p1.x, floor_height / 2.0, p1.y)
		var p2t = Vector3(p2.x, floor_height / 2.0, p2.y)
		var dir = (p2t - p1t).normalized()
		var pcur = p1t + dir * offset
		for h in range(window_count):
			var window = CSGMesh.new()
			window.mesh = window_mesh
			window.operation = CSGShape.OPERATION_SUBTRACTION
			combiner.add_child(window)
			window.translation = pcur
			window.rotation.y = d
			pcur += dir * window_spacing
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
