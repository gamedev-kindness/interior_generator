extends Camera

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_up"):
		global_translate(Vector3(0, 0, delta * 5))
	if Input.is_action_pressed("ui_down"):
		global_translate(Vector3(0, 0, -delta * 5))
	if Input.is_action_pressed("ui_left"):
		global_translate(Vector3(-delta * 5, 0, 0))
	if Input.is_action_pressed("ui_right"):
		global_translate(Vector3(delta * 5, 0, 0))
	look_at(Vector3(0, 0, 0), Vector3(0, 1, 0))
