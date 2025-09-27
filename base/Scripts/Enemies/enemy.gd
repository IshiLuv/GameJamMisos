extends Entity
class_name Enemy

var bullet_scene = preload("res://Scenes/Bullets/bullet.tscn")

var can_shoot: bool = false
var target

@onready var gun_marker = $Sprite2D/Gun_marker

func die():
	Sounds.play_sound(global_position,"enemy_died" + str(randf_range(1,3)), 0.0, "SFX", 0.0, 1.0)
	queue_free()

func _physics_process(_delta: float) -> void:
	if target != null:
		$Sprite2D.scale.x = -1 if target.global_position[0] < global_position[0] else 1
		if can_shoot:
			can_shoot = false
			$ShootCD.start()
			Sounds.play_sound(global_position,"enemy_attack", -5.0, "SFX", 0.2, 1.0)
			G.spawn_bullet(self, bullet_scene, gun_marker.global_position,  gun_marker.global_position.direction_to(target.global_position))

func _on_shoot_cd_timeout() -> void:
	can_shoot = true

func _on_aggro_range_body_entered(body: Node2D) -> void:
	if body is Player:
		target = body
		$ShootCD.start()

func _on_aggro_range_body_exited(body: Node2D) -> void:
	if body is Player:
		target = null
