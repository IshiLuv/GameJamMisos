extends Node2D
class_name Main
var onPause: bool = false


func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://settings_menu.tscn")


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://lose.tscn")


func _on_button_1_pressed() -> void:
	print(2)
