extends Node
var onPause: bool = false
@export var skipIntro: bool = false
func _ready() -> void:
	for scene in get_tree().get_root().get_children():
		if scene is Main :
			scene.queue_free()
			
			
	
	if !skipIntro:
		await get_tree().create_timer(1).timeout
		Animations.appear($Unreal_fake)
		$Unreal_fake.play()
		await get_tree().create_timer(3).timeout
		Animations.appear($ColorRect2)
		await get_tree().create_timer(0.1).timeout
		Animations.disappear($Unreal_fake)
		Animations.disappear($ColorRect2)
		await get_tree().create_timer(0.25).timeout
		Animations.appear($Gogot_logo)
		await get_tree().create_timer(2).timeout
		Animations.disappear($Gogot_logo)
		await get_tree().create_timer(1).timeout
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
	else: $ColorRect.visible = false
	
	
	
	
	
	
	
	
	

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://settings_menu.tscn")


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
