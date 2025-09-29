extends Enemy

@export var wander_radius: float = 50.0
@export var move_speed: float = 80.0
@export var attack_range: float = 200.0   # ближе, чем для стрельбы
@export var dash_speed: float = 400.0     # скорость рывка
@export var dash_duration: float = 0.9   # длительность рывка

var spawn_position: Vector2
var wander_target: Vector2

enum State { IDLE, WALK, DASH }
var state: State = State.IDLE

func _ready() -> void:
	G.spawned_enemies += 1
	max_health += G.spawned_enemies
	health = max_health
	spawn_position = global_position
	wander_target = global_position
	$StepTimer.stop()
	$Sprite2D.frame = 0

func _physics_process(delta: float) -> void:
	match state:
		State.WALK:
			_process_walk(delta)
		State.DASH:
			# рывок обрабатывается в корутине dash()
			move_and_slide()
		State.IDLE:
			_process_idle(delta)

	# шаги только при ходьбе
	if state == State.WALK and velocity.length() > 0.1:
		if $StepTimer.is_stopped():
			$StepTimer.start()
	else:
		if not $StepTimer.is_stopped():
			$StepTimer.stop()

	# ориентация по игроку
	if target:
		$Sprite2D.scale.x = 1.4 if target.global_position.x < global_position.x else -1.4

var idle_t: float = 0.0
func _process_idle(delta: float) -> void:
	velocity = Vector2.ZERO
	move_and_slide()
	idle_t += delta * 2.0
	var scale_y = lerp(scale.y, 1.0 + sin(idle_t) * 0.05, 0.1)
	scale.y = scale_y

func _process_walk(_delta: float) -> void:
	if target:

		if !$ShootCD.is_stopped():
			var dir = (target.global_position - global_position).normalized()
			velocity = dir * move_speed
			move_and_slide()
		else:
			velocity = Vector2.ZERO
			move_and_slide()
			dash()
	else:
		# блуждание
		if global_position.distance_to(wander_target) < 10:
			var angle = randf_range(0, TAU)
			var offset = Vector2.RIGHT.rotated(angle) * randf_range(20, wander_radius)
			wander_target = spawn_position + offset
		
		var dir = (wander_target - global_position).normalized()
		velocity = dir * move_speed * 0.5
		move_and_slide()

func dash() -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(false)
	tween.tween_property(self, "scale", Vector2(1.0, 0.8), 0.5)
	tween.tween_property(self, "scale", Vector2(0.8, 1.0), 0.3)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.1)
	
	can_shoot = false
	state = State.DASH
	$StepTimer.stop()

	await get_tree().create_timer(0.2).timeout

	if target:
		var dir = (target.global_position - global_position).normalized()
		velocity = dir * dash_speed
	else:
		velocity = Vector2.ZERO

	Sounds.play_sound(global_position, "enemy_attack", -2.0, "SFX", 0.2, 1.0)

	# длительность рывка
	await get_tree().create_timer(dash_duration).timeout

	# сброс
	velocity = Vector2.ZERO
	$Sprite2D.frame = 0
	state = State.WALK
	$ShootCD.start()  # перезарядка между рывками

func _on_shoot_cd_timeout() -> void:
	can_shoot = true

func _on_aggro_range_body_entered(body: Node2D) -> void:
	if body and body is Player:
		target = body
		$ShootCD.start()
		state = State.WALK

func _on_aggro_range_body_exited(body: Node2D) -> void:
	if body is Player:
		target = null
		state = State.WALK

func _on_step_timer_timeout() -> void:
	if state == State.WALK and velocity.length() > 0.1:
		Animations.shakeCam(G.main.player.get_node("Camera2D"), 0.1)
		Sounds.play_sound(global_position, "stick" + str(randi_range(1, 5)), -12.0, "SFX", 0.1, 0.5)
		$Sprite2D.frame = 0 if $Sprite2D.frame == 1 else 1
		
func take_damage(dmg):
	if self is Enemy:
		Sounds.play_sound(global_position,"enemy_hurt", -6.0, "SFX", 0.0, 1.0)
	
	await Animations.flash(self,-10)
	health -= dmg
	await get_tree().create_timer(0.1).timeout
	if health <= 0:
		die()
