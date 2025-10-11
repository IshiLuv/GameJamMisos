extends Node2D

func _ready() -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)
	tween.tween_property($Hat, "global_position", Vector2(969,413.438), 3.1)
	tween.tween_property($Camera2D, "zoom", Vector2(1.4,1.4), 5.1)
	await get_tree().create_timer(3.6).timeout
	Animations.appear($ColorRect,10)
	
func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
