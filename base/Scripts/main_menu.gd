extends Node2D

var onPause: bool = false
@export var skipIntro: bool = false

func _ready() -> void:
	G.main_menu = self
	
	for scene in get_tree().get_root().get_children():
		if scene is Main :
			scene.queue_free()
			
	if !skipIntro:
		await get_tree().create_timer(1).timeout
		Animations.appear($Fake_unreal)
		$Fake_unreal.play()
		await get_tree().create_timer(6.5).timeout
		Animations.disappear($Fake_unreal)
		Animations.appear($JamLogo)
		#$AudioStreamPlayer.play()
		await get_tree().create_timer(1.5).timeout
		Animations.disappear($JamLogo)
		await get_tree().create_timer(1.5).timeout
		Animations.appear($Intro,2)
		$Intro.play()
		await get_tree().create_timer(4).timeout
		Animations.disappear($Intro)
		await get_tree().create_timer(1).timeout
		Animations.disappear($ColorRect)
	else: 
		$ColorRect.visible = false
		$Fake_unreal.visible = false
	
func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/settings_menu.tscn")

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
