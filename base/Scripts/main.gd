extends Node2D
class_name Main
var onPause: bool = false
@onready var player = $Character

func _ready() -> void:
	G.main = self
	G.spawned_enemies = 0
	Animations.appear(self)
	Sounds.set_music("main_song")
	$Levels/Level/Enemy.max_health = 10
	$Levels/Level/Enemy.health = $Levels/Level/Enemy.max_health
	generate($Levels/Level)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	await get_tree().create_timer(0.6).timeout
	if !G.watchedCutscene2:
		var hat_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(false)
		hat_tween.tween_property($Camera2D, "zoom", Vector2(1.0,1.0), 1.5)
		hat_tween.tween_property($Camera2D, "zoom", Vector2(0.3,0.3), 6.5)
		hat_tween.set_parallel(true)
		hat_tween.tween_property($Camera2D, "position", $Character.global_position, 7.5)
		hat_tween.set_parallel(false)
		hat_tween.tween_property($Camera2D, "zoom", Vector2(1.2,1.2), 1.5)
		await get_tree().create_timer(10.5).timeout
		G.watchedCutscene2 = true
	$Camera2D.enabled = false
	
func generate(last_level):
	var layers_list = []
	
	for i in 10:
		var id = str(randi_range(1,2))
		if i>3:
			id = str(randi_range(1,4))
		if i == 9:
			id = str(0)
		var new_level = load("res://Scenes/levels/level_" + id + ".tscn").instantiate()
		$Levels.add_child(new_level)
		new_level.global_position = last_level.get_node("Level_end").global_position
		layers_list.append([new_level.get_node("TileMapLayer"),Vector2i(new_level.get_node("Level_end").position.x/64,new_level.get_node("Level_end").position.y/48)])
		new_level.get_node("TileMapLayer").queue_free()
		new_level.get_node("Level_end").queue_free()
		last_level = new_level
		
	
	$Levels/Level.get_node("TileMapLayer").merge_layers(layers_list)
