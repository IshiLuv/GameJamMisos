extends Bullet

func _ready() -> void:
	damage = 20
	if is_burning:
		Sounds.play_sound(global_position,"gg_attack_fire", 0.0, "SFX", 0.4, 2.0)
		$BurnParticle.emitting = true
	else:
		$BurnParticle.emitting = false


func _process(delta: float) -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body and body is Entity:
		if sender and sender is Player:
			sender.on_bullet_land(self)
		if is_burning:
			body.set_burning()
		body.take_damage(damage)
		if body and body is Player and !body.can_take_damage:
			return
		queue_free()
