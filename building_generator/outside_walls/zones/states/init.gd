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
func run(obj):
	if !check_polygon_grid(obj, obj.shape.segments, obj.global_transform):
		obj.queue_free()
	elif obj.outside_walls_obj.budget < 4:
		obj.queue_free()
	else:
		obj.update_shape_grid()
		obj.report_spawned()
		return "next"
func init(obj):
	pass
