extends Entity
class_name Enemy

var bullet_scene = preload("res://Scenes/Bullets/bullet.tscn")

var can_shoot: bool = false
var target

func _physics_process(_delta: float) -> void:
	if target != null and can_shoot:
		can_shoot = false
		$ShootCD.start()
		G.spawn_bullet(self, bullet_scene, global_position,  global_position.direction_to(target.global_position))

func _on_shoot_cd_timeout() -> void:
	can_shoot = true

func _on_aggro_range_body_entered(body: Node2D) -> void:
	if body is Player:
		target = body
		$ShootCD.start()

func _on_aggro_range_body_exited(body: Node2D) -> void:
	if body is Player:
		target = null
