extends CharacterBody2D

@export var speed: float = 50.0
@export var wander_radius: float = 200.0
@export var wait_time: float = 1.0

var target_position: Vector2
var waiting: bool = false
var wait_timer: float = 0.

func _ready():
	choose_new_target()
func _physics_process(delta):
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false  
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = true 
	
	
	if waiting:
		wait_timer -= delta
		if wait_timer <= 0:
			waiting = false
			choose_new_target()
		return
	var direction = (target_position - global_position).normalized()
	velocity = direction * speed
	$AnimatedSprite2D.play('run')
	move_and_slide()
	
	if global_position.distance_to(target_position) < 10.0:
		start_waiting()

func choose_new_target():
	var random_offset = Vector2(
		randf_range(-wander_radius, wander_radius),
		randf_range(-wander_radius, wander_radius)
	)
	target_position = global_position + random_offset

func start_waiting():
	$AnimatedSprite2D.play('idle')
	waiting = true
	wait_timer = wait_time
	velocity = Vector2.ZERO
