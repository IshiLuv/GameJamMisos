extends Node2D

var onPause: bool = false
@export var skipIntro: bool = false
@export var isWebBuild: bool = false
var pause_menu: Control
signal pause_pressed

func _ready() -> void:
	for scene in get_tree().get_root().get_children():
		if scene is Main :
			scene.queue_free()
	$VBoxContainer/Exit.visible = !isWebBuild
	Sounds.stop_music()
	
	if !skipIntro and !G.watchedIntro:
		$For_eye.disabled = true
		await get_tree().create_timer(1).timeout
		Animations.appear($Fake_unreal)
		$Fake_unreal.play()
		await get_tree().create_timer(6.5).timeout
		Animations.disappear($Fake_unreal)
		Animations.appear($JamLogo)
		await get_tree().create_timer(1.5).timeout
		Animations.disappear($JamLogo)
		await get_tree().create_timer(1.5).timeout
		Animations.appear($Intro,2)
		$Intro.play()
		await get_tree().create_timer(4).timeout
		Animations.disappear($Intro)
		await get_tree().create_timer(1).timeout
		Animations.disappear($ColorRect)
		G.watchedIntro = true
		$For_eye.disabled = false
	else: 
		$ColorRect.visible = false
		$Fake_unreal.visible = false
	Sounds.set_music("aboba (online-audio-converter.com)")
	
func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	toggle_pause()

func _on_play_pressed() -> void:
	if !G.watchedCutscene and !skipIntro:
		$Eye.visible = false
		$For_eye.disabled = true
		G.watchedCutscene = true
		$Cutscene.visible = true
		$Cutscene.play()
		Sounds.set_music("")
		await get_tree().create_timer(25).timeout
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_control_pressed() -> void:
	$Eye.visible = true
	$Eye.play('Fire')
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if !$Fake_unreal.visible and !$Cutscene.visible:
			toggle_pause()
		else:
			G.watchedIntro = true
			G.watchedCutscene = true
			get_tree().change_scene_to_file("res://Scenes/main.tscn")
			
func toggle_pause():
	if get_tree().paused:
		_resume_game()
	else:
		_pause_game()
	
func _pause_game():
	get_tree().paused = true
	pause_menu = load("res://Scenes/settings_menu.tscn").instantiate()
	add_child(pause_menu)

func _resume_game():
	get_tree().paused = false
	if pause_menu and pause_menu.is_inside_tree():
		pause_menu.queue_free()
func _exit_to_main_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
