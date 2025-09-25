extends Node2D
@export var based_screen: Vector2i =  DisplayServer.screen_get_size()
func _ready() -> void:
	$AudioStreamPlayer2D.play()
	$Button.text = "Полноэкранный"
	$OptionButton.select(4)
	$OptionButton.set_item_text(4, str(based_screen[0]) + "×" + str(based_screen[1]))
	
func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _on_h_slider_value_changed(value: float) -> void:
	if value == -25: 
		AudioServer.set_bus_volume_db(2, -80)
	else: AudioServer.set_bus_volume_db(2, value)
	


func _on_option_button_item_selected(index: int) -> void:
	if index==0:
		DisplayServer.window_set_size(Vector2i(1920, 1080))
		Glo.last_index = index
	elif index==1:
		DisplayServer.window_set_size(Vector2i(1366,768))
		Glo.last_index = index
	elif index==2:
		DisplayServer.window_set_size(Vector2i(1280,1024))
		Glo.last_index = index
	elif index==3:
		DisplayServer.window_set_size(Vector2i(2560,1440))
		Glo.last_index = index
	elif index==4:
		DisplayServer.window_set_size(based_screen)
	 
		
func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		$Button.text = "Оконный"
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	if toggled_on == false:
		$Button.text = "Полноэкранный"
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
		
		
		

		
		
		
		
		
		
		
		
		
