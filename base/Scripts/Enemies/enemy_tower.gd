extends Enemy

func _physics_process(_delta: float) -> void:
	if target != null:
		$Sprite2D.scale.x = -1 if target.global_position[0] < global_position[0] else 1
		if can_shoot:
			$Sprite2D.frame = 1
			can_shoot = false
			$ShootCD.start()
			for i in 10:
				$Sprite2D.frame = i%2
				if target:
					G.spawn_bullet(self, bullet_scene, gun_marker.global_position,  gun_marker.global_position.direction_to(target.global_position))
					await get_tree().create_timer(0.05).timeout
			$Sprite2D.frame = 0

func _on_shoot_cd_timeout() -> void:
	can_shoot = true

func _on_aggro_range_body_entered(body: Node2D) -> void:
	if body and body is Player:
		target = body
		$ShootCD.start()

func _on_aggro_range_body_exited(body: Node2D) -> void:
	if body and body is Player:
		target = null
