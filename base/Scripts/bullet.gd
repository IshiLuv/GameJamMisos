extends Node2D
class_name Bullet

@export var speed: int = 600
var direction: Vector2 = Vector2.UP 
var damage: int = 1
var sender

func _ready() -> void:
	if direction[0] < 0:
		$Sprite2D.flip_h = true
	await get_tree().create_timer(3).timeout
	queue_free()

func _process(delta: float) -> void:
	global_position += direction * delta * speed

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Entity:
		if sender is Player:
			sender.on_bullet_land(self)
		body.take_damage(damage)
		queue_free()
