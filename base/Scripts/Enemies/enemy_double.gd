extends Enemy

func _physics_process(_delta: float) -> void:
	if target != null and can_shoot:
		can_shoot = false
		$ShootCD.start()
		
		var dir := global_position.direction_to(target.global_position)
		
		var spread = deg_to_rad(15)
		
		var dir_left = dir.rotated(-spread)
		var dir_right = dir.rotated(spread)

		G.spawn_bullet(self, bullet_scene, global_position, dir_left)
		G.spawn_bullet(self, bullet_scene, global_position, dir_right)

func _on_shoot_cd_timeout() -> void:
	can_shoot = true

func _on_aggro_range_body_entered(body: Node2D) -> void:
	if body and body is Player:
		target = body
		$ShootCD.start()

func _on_aggro_range_body_exited(body: Node2D) -> void:
	if body and body is Player:
		target = null
