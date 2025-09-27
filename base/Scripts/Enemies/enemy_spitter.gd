extends Enemy

@export var wander_radius: float = 50.0
@export var move_speed: float = 80.0
@export var attack_range: float = 300.0

var spawn_position: Vector2
var wander_target: Vector2

enum State { IDLE, WALK, SHOOT }
var state: State = State.IDLE

func _ready() -> void:
	spawn_position = global_position
	wander_target = global_position
	$StepTimer.stop()
	$Sprite2D.frame = 0


func _physics_process(delta: float) -> void:
	match state:
		State.WALK:
			_process_walk(delta)
		State.SHOOT:
			velocity = Vector2.ZERO
			move_and_slide()
		State.IDLE:
			velocity = Vector2.ZERO
			move_and_slide()

	# управление шагами — только если реально движется
	if state == State.WALK and velocity.length() > 0.1:
		if $StepTimer.is_stopped():
			$StepTimer.start()
	else:
		if not $StepTimer.is_stopped():
			$StepTimer.stop()

func _process_walk(_delta: float) -> void:
	if target:
		var distance = global_position.distance_to(target.global_position)
		if distance > attack_range:
			var dir = (target.global_position - global_position).normalized()
			velocity = dir * move_speed
			$Sprite2D.scale.x = -1 if dir.x < 0 else 1
			move_and_slide()
		else:
			velocity = Vector2.ZERO
			move_and_slide()
			if can_shoot:
				attack()
	else:
		# блуждание
		if global_position.distance_to(wander_target) < 10:
			var angle = randf_range(0, TAU)
			var offset = Vector2.RIGHT.rotated(angle) * randf_range(20, wander_radius)
			wander_target = spawn_position + offset
		
		var dir = (wander_target - global_position).normalized()
		velocity = dir * move_speed * 0.5
		$Sprite2D.scale.x = -1 if dir.x < 0 else 1
		move_and_slide()

func attack() -> void:
	can_shoot = false
	state = State.SHOOT
	velocity = Vector2.ZERO
	$StepTimer.stop()

	# корутина в Godot 4.5
	await _do_attack()

func _do_attack() -> void:
	$Sprite2D.frame = 2
	
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(false)
	tween.tween_property(self, "scale", Vector2(1.0, 0.8), 0.5)
	tween.tween_property(self, "scale", Vector2(0.8, 1.0), 0.3)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.1)
	
	await get_tree().create_timer(0.5).timeout
	
	$Sprite2D.frame = 3
	await get_tree().create_timer(0.1).timeout
	
	$ShootCD.start()
	Sounds.play_sound(global_position, "enemy_attack", -2.0, "SFX", 0.2, 1.0)
	G.spawn_bullet(self, bullet_scene, gun_marker.global_position, gun_marker.global_position.direction_to(target.global_position))
	
	$Sprite2D.frame = 0
	state = State.WALK

func _on_shoot_cd_timeout() -> void:
	can_shoot = true

func _on_aggro_range_body_entered(body: Node2D) -> void:
	if body is Player:
		target = body
		$ShootCD.start()
		state = State.WALK

func _on_aggro_range_body_exited(body: Node2D) -> void:
	if body is Player:
		target = null
		state = State.WALK
		
func _on_step_timer_timeout() -> void:
	# звук шагов только если реально идёт
	if state == State.WALK and velocity.length() > 0.1:
		Sounds.play_sound(global_position, "stick" + str(randi_range(1, 5)), -12.0, "SFX", 0.1, 0.5)
		$Sprite2D.frame = 0 if $Sprite2D.frame == 1 else 1
