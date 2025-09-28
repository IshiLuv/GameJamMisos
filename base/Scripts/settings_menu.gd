extends Control

func _ready() -> void:
	self.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.25)
	$OptionButton.select(G.resolution) 
	$OptionButton.set_item_text(4, str(G.based_screen[0]) + "×" + str(G.based_screen[1]))
	$AnimatedSprite2D.set_frame_and_progress(G.frame_music,0)
	$AnimatedSprite2D.pause()
	$AnimatedSprite2D2.set_frame_and_progress(G.frame_svx,0)
	$AnimatedSprite2D2.pause()
	$AnimatedSprite2D2/SVX.set_value_no_signal(AudioServer.get_bus_volume_db(1))
	$AnimatedSprite2D/Music.set_value_no_signal(AudioServer.get_bus_volume_db(2))
	
func _on_exit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	
	
func _on_option_button_item_selected(index: int) -> void:
	if index==0:
		DisplayServer.window_set_size(Vector2i(1920, 1080))
		G.resolution = index
	elif index==1:
		DisplayServer.window_set_size(Vector2i(1366,768))
		G.resolution = index
	elif index==2:
		DisplayServer.window_set_size(Vector2i(1280,1024))
		G.resolution = index
	elif index==3:
		DisplayServer.window_set_size(Vector2i(2560,1440))
		G.resolution = index
	elif index==4:
		DisplayServer.window_set_size(G.based_screen)
	 
func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		$Button.texture_normal = load("res://Assets/UI/WINDOWED.png")
		DisplayServer.window_set_size(G.based_screen)
		G.resolution = 4
		$OptionButton.select(G.resolution)
		$OptionButton.set_item_text(4, str(G.based_screen[0]) + "×" + str(G.based_screen[1]))
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	if toggled_on == false:
		$Button.texture_normal = load("res://Assets/UI/Fullscreen.png")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		


func _on_music_value_changed(value: float) -> void:
	if value == -25: 
		AudioServer.set_bus_volume_db(2, -80)
	else: 
		AudioServer.set_bus_volume_db(2, value)
		var t = float(value +25 ) / float(20 + 25)
		G.frame_music = int(round(t * (7 - 1)))
		$AnimatedSprite2D.play("Slaider")
		$AnimatedSprite2D.set_frame_and_progress(G.frame_music,0)
		$AnimatedSprite2D.pause()


func _on_svx_value_changed(value: float) -> void:
	if value == -25: 
		AudioServer.set_bus_volume_db(1, -80)
	else: 
		AudioServer.set_bus_volume_db(1, value)
		var t = float(value + 25 ) / float(20 + 25)
		G.frame_svx = int(round(t * (7 - 1)))
		$AnimatedSprite2D2.play("Slaider")
		$AnimatedSprite2D2.set_frame_and_progress(G.frame_svx,0)
		$AnimatedSprite2D2.pause()

func _process(delta: float) -> void:
	if Input.is_action_just_released("pause"):
		G.watchedIntro = true
		get_tree().paused = false
		queue_free()

func _on_return_pressed() -> void:
	G.watchedIntro = true
	get_tree().paused = false
	queue_free()
