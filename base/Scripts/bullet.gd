extends Node2D
class_name Bullet

@export var speed: int = 600
var direction: Vector2 = Vector2.UP 
var col_mask = 2 
var damage: int = 1

var bullet_texture: Texture = load("res://Assets/Textures/bullet.png")

func _ready() -> void:
	$Sprite2D.texture = bullet_texture
	$Area2D.collision_mask = 1 << (col_mask - 1)  # сдвиг бита в позицию слоя
	if direction[0] < 0:
		$Sprite2D.flip_h = true
	await get_tree().create_timer(3).timeout
	queue_free()

func _process(delta: float) -> void:
	global_position += direction * delta * speed


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Enemy or body is Player:
		body.take_damage(damage)
		queue_free()
