extends Node2D
class_name Bullet

@export var speed: int = 600
var direction: Vector2 = Vector2.UP 
var damage: int = 1
var sender

var is_burning: bool = false

func _ready() -> void:
	if is_burning:
		Sounds.play_sound(global_position,"gg_attack_fire", -0.0, "SFX", 0.4, 2.0)
		$BurnParticle.emitting = true
	else:
		$BurnParticle.emitting = false
	$Sprite2D.flip_h = direction[0] < 0
	await get_tree().create_timer(3).timeout
	queue_free()

func _process(delta: float) -> void:
	global_position += direction * delta * speed

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body and body is Entity:
		if sender is Player:
			sender.on_bullet_land(self)
		if is_burning:
			body.set_burning()
		body.take_damage(damage)
		queue_free()
