extends Node2D
class_name Main

@onready var player = $Character

func _ready() -> void:
	G.main = self
	Animations.appear(self)
	generate()

func generate():
	var last_level = $Levels/Level
	for i in 3:
		var new_level = load("res://Scenes/levels/level_1.tscn").instantiate()
		$Levels.add_child(new_level)
		new_level.global_position = last_level.get_node("Level_end").global_position
		last_level = new_level
	
