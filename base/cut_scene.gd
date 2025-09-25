extends Node
func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	$ColorRect.visible=false
	$main_pic.visible=true
	await get_tree().create_timer(2).timeout
	$ColorRect.visible=true
	await get_tree().create_timer(0.25).timeout
	$ColorRect.visible=false
	$main_pic.texture = load("res://Texture/photo_2025-06-19_14-46-45.jpg")
	await get_tree().create_timer(2).timeout
	$ColorRect.visible=true
	get_tree().change_scene_to_file("res://main.tscn")
