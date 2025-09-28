extends Node2D
class_name Main
var onPause: bool = false
@onready var player = $Character

func _ready() -> void:
	G.main = self
	Animations.appear(self)
	generate()
	

func generate():
	var last_level = $Levels/Level
	var layers_list = []
	
	for i in 10:
		var new_level = load("res://Scenes/levels/level_1.tscn").instantiate()
		$Levels.add_child(new_level)
		new_level.global_position = last_level.get_node("Level_end").global_position
		layers_list.append([new_level.get_node("TileMapLayer"),Vector2i(new_level.get_node("Level_end").position.x/64,new_level.get_node("Level_end").position.y/48)])
		new_level.get_node("TileMapLayer").queue_free()
		new_level.get_node("Level_end").queue_free()
		last_level = new_level
	$Levels/Level.get_node("TileMapLayer").merge_layers(layers_list)
