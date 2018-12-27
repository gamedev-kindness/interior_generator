extends Node

func _ready():
	pass # Replace with function body.
var state = 0
export var repeat = 1
func run(obj):
	var cur =  get_children()[state]
	var next = cur.run(obj)
	if next == "next":
		state += 1
	if next == "prev":
		state -= 1
	if state < 0:
		state = 0
		return "prev"
	elif state >= get_children().size():
		if repeat == 0:
			state = 0
			return "next"
		else:
			state = 0
			repeat -= 1
#			print("again ", get_children()[state].name)
			get_children()[state].init(obj)
	elif next == "next":
		get_children()[state].init(obj)
func init(obj):
	var cur =  get_children()[state]
	cur.init(obj)
	state = 0
