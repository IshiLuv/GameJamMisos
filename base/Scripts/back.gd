extends Control
var base_position = Vector2.ZERO
func _ready():
	base_position = position 

func _process(_a):
	var center = get_viewport().size / 4
	var mouse_pos = get_viewport().get_mouse_position()
	var a = (mouse_pos - Vector2(center))
	position = base_position - a / 15
