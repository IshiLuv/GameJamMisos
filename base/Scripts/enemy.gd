extends CharacterBody2D
class_name Enemy

var bullet_scene = preload("res://Scenes/bullet.tscn")

var max_health: int = 10
var health: int = max_health

func _ready() -> void:
	while true:
		await get_tree().create_timer(1.6).timeout
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.direction = global_position.direction_to(G.main.player.global_position)
		bullet.col_mask = 4
		G.main.add_child(bullet)
		
func take_damage(dmg):
	await Animations.flash(self,5)
	health -= dmg
	if health <= 0:
		die()
		
func die():
	queue_free()
	
