extends Node2D

func _ready() -> void:
	$AudioStreamPlayer2D.play()
	$Button.text = "Полноэкранный"
	$OptionButton.select(G.resolution) 
	$OptionButton.set_item_text(4, str(G.based_screen[0]) + "×" + str(G.based_screen[1]))
	
func _on_exit_pressed() -> void:
	G.main.skipIntro = true
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_h_slider_value_changed(value: float) -> void:
	if value == -25: 
		AudioServer.set_bus_volume_db(2, -80)
	else: AudioServer.set_bus_volume_db(2, value)
	
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
		$Button.text = "Оконный"
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	if toggled_on == false:
		$Button.text = "Полноэкранный"
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
