extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func process_point(point):
#	print(point)
	$display_data.spawn_points.push_back(point)
	$display_data.update()
func windows_ready():
	$display_data.windows = $build_floor.windows_pos
	print("children count: ", $build_floor/windows.get_child_count())
	$display_data.update()
func _ready():
	var poly = $Polygon2D.polygon
	$display_data.set_poly(poly)
	$build_floor.init(poly, transform)
	$build_floor.connect("spawn_point", self, "process_point")
	$build_floor.connect("windows_ready", self, "windows_ready")

func _process(delta):
	$display_data.update()
