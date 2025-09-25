extends Node
var main: Node2D
var volume: float = 0.0
var last_index: int = 0.0
var based_screen: Vector2i =  DisplayServer.screen_get_size()
var skipIntro: bool = false

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
