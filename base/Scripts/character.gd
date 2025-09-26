extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_force: float = 600.0
@export var jump_duration: float = 0.2

var input_dir: Vector2
var jump_velocity: Vector2
var is_jumping: bool = false
var jump_timer: float

func _process(_delta: float) -> void:
	input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	
	if input_dir != Vector2.ZERO:
		$Sprite/Arrows.visible = true
		$Sprite/Arrows.position = input_dir*70 + Vector2(0,4)
		$Sprite/Arrows.rotation = input_dir.angle()
	else:
		$Sprite/Arrows.visible = false
			
	if Input.is_action_just_pressed("jump") and !is_jumping:
		is_jumping = true
		jump()
		jump_velocity = input_dir * jump_force
		jump_timer = jump_duration

func _physics_process(delta: float) -> void:
	if is_jumping:
		velocity = jump_velocity
		jump_timer -= delta
		if jump_timer <= 0.0:
			is_jumping = false
			$Sprite/Arrows.visible = true
			velocity = Vector2.ZERO
	
	move_and_slide()
	
func jump():
	$Sprite/Arrows.visible = false
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(false)
	tween.tween_property($Sprite/Body, "position", Vector2(0, -50.0), 0.1)
	tween.tween_property($Sprite/Head, "position", Vector2(-2, -66.5), 0.1)
	tween.tween_property($Sprite/Body, "position", Vector2(0, -40.0), 0.1)
	tween.tween_property($Sprite/Head, "position", Vector2(-2, -60.5), 0.1)
	
	
