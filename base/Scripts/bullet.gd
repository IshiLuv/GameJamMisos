extends Node2D
class_name Bullet

@export var speed: int = 450
var direction: Vector2 = Vector2.ZERO 
var damage: int = 1
var sender

var target = null

var is_autoaim: bool = false
var is_burning: bool = false
var is_spinning: bool = false
var do_flip: bool = true


func _ready() -> void:
	
	damage *= sender.bullet_damage_mult
	if is_burning:
		Sounds.play_sound(global_position,"gg_attack_fire", 0.0, "SFX", 0.4, 2.0)
		$BurnParticle.emitting = true
	else:
		$BurnParticle.emitting = false
	if do_flip: $Sprite2D.flip_v = direction[0] < 0
	$Aim.monitoring = is_autoaim
	
	await get_tree().create_timer(2).timeout
	queue_free()

func _process(delta: float) -> void:
	if is_spinning:
		$Sprite2D.rotation += deg_to_rad(360) * delta
	if target: direction = global_position.direction_to(target.global_position)
	rotation = direction.angle()
	global_position += direction * delta * speed

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


func _on_aim_body_entered(body: Node2D) -> void:
	if body is Enemy:
		target = body
