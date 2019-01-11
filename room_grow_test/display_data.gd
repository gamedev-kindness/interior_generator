extends ColorRect

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var polygon: PoolVector2Array
var spawn_points
var windows
var prect: Rect2
func _ready():
	pass
func set_poly(poly):
	polygon = poly
	prect = Rect2()
	for p in polygon:
		prect = prect.expand(p)
	spawn_points = []

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _draw():
	if polygon != null:
		var colors = []
		var points = []
		var scale_x = rect_size.x / prect.size.x * 0.9
		var scale_y = rect_size.y / prect.size.y * 0.9
		var poffset = Vector2(prect.size.x / 2, prect.size.y / 2)
		var offset = Vector2(rect_size.x / 2, rect_size.y / 2)
		var scale = min(scale_x, scale_y)
		for k in polygon:
			colors.push_back(Color(0, 1, 0))
			points.push_back((k - prect.position - poffset) * scale + offset)
		draw_polygon(PoolVector2Array(points), PoolColorArray(colors))
		if spawn_points != null:
			for p in spawn_points:
				draw_circle((p - prect.position - poffset) * scale + offset, 3.0, Color(1, 0, 0)) 
		for f in get_tree().get_nodes_in_group("windows"):
			var wpoints = []
			var wcolors = []
			for pt in f.polygon:
				wpoints.push_back((f.transform.xform(pt) - prect.position - poffset) * scale + offset)
				wcolors.push_back(Color(0, 0, 0.5))
			draw_polygon(PoolVector2Array(wpoints), PoolColorArray(wcolors))
		for f in get_tree().get_nodes_in_group("rooms"):
			var rpoints = []
			var rcolors = []
			for pt in f.polygon:
				rpoints.push_back((f.transform.xform(pt) - prect.position - poffset) * scale + offset)
				rcolors.push_back(Color(0.5, 1.0, 0.5))
			draw_polygon(PoolVector2Array(rpoints), PoolColorArray(rcolors))