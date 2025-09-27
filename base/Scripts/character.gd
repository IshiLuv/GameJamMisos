extends Entity
class_name Player

@export var speed: float = 200.0
@export var min_jump_force: float = 300.0
@export var max_jump_force: float = 800.0
@export var max_charge_time: float = 1.0

var bullet_scene = preload("res://Scenes/Bullets/bullet_player.tscn")

var items: Array = []
var active_item: String = ""

var input_dir: Vector2
var jump_velocity: Vector2

var special_attack_cost: int = 100
var special_attack_charge: int = 0

var charge_timer: float = 0.0
var jump_timer: float = 0.0

var is_jumping: bool = false
var is_charging_jump: bool = false
var is_shaking: bool = false
var can_move: bool = true
var can_take_damage: bool = true

func _ready() -> void:
	$Sprite/Head.material.set_shader_parameter("dissolve_value", 1.0)
	health = max_health
	update_health()
	
func _process(delta: float) -> void:
	
	if can_move:
		input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()

		if input_dir != Vector2.ZERO:
			$Sprite/Arrows.visible = true
			$Sprite/Arrows.position = input_dir * 70 + Vector2(0, 4)
			$Sprite/Arrows.rotation = input_dir.angle()
		else:
			$Sprite/Arrows.visible = false

		if Input.is_action_just_pressed("attack"):
			if $AttackCD.is_stopped():
				$AttackCD.start()
				attack()

		if Input.is_action_just_pressed("alt_attack"):
			if $AltAttackCD.is_stopped():
				$AltAttackCD.start()
				$Sprite/Head.texture = load("res://Assets/Textures/character2.png")
				alt_attack()

		if Input.is_action_just_pressed("special_attack"):
			special_attack()

		if Input.is_action_pressed("jump") and !is_jumping:
			is_charging_jump = true
			charge_timer = min(charge_timer + delta*1.5, max_charge_time)
			shakeLoop()

		if Input.is_action_just_released("jump") and is_charging_jump and !is_jumping:
			start_jump()

func _physics_process(delta: float) -> void:
	if can_move and is_jumping:
		velocity = jump_velocity
		jump_timer -= delta
		if jump_timer <= 0.0:
			is_jumping = false
			$Sprite/Arrows.visible = true
			velocity = Vector2.ZERO
			$Hurtbox/CollisionShape2D.disabled = false
			Animations.shakeCam($Camera2D, 0.4)

	move_and_slide()

func start_jump():
	is_charging_jump = false
	is_jumping = true
	$Hurtbox/CollisionShape2D.disabled = true
	
	var charge_percent = charge_timer / max_charge_time
	var force = lerp(min_jump_force, max_jump_force, charge_percent) + floor(charge_percent)*50
	jump()

	jump_velocity = input_dir * force 
	jump_timer = 0.2
	charge_timer = 0.0

func jump():
	Animations.shakeCam($Camera2D, 0.5)
	$Sprite/Arrows.visible = false
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(false)
	tween.tween_property($Sprite/Body, "position", Vector2(0, -50.0-charge_timer*20), 0.05)
	tween.tween_property($Sprite/Head, "position", Vector2(-2, -66.5-charge_timer*10), 0.1)
	tween.tween_property($Sprite/Body, "position", Vector2(0, -40.0), 0.1)
	tween.tween_property($Sprite/Head, "position", Vector2(-2, -60.5), 0.1)

func attack():
	Animations.shakeCam($Camera2D, 1)
	$Sprite/Arrows.visible = false
	
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(false)
	tween.tween_property($Sprite/Body, "position", Vector2(0, -50.0), 0.03)
	tween.tween_property($Sprite/Head, "position", Vector2(-2, -66.5), 0.1)
	tween.tween_property($Sprite/Body, "position", Vector2(0, -40.0), 0.1)
	tween.tween_property($Sprite/Head, "position", Vector2(-2, -60.5), 0.1)
	
	G.spawn_bullet(self, bullet_scene, $Gun/Bullet_Marker.global_position, $Gun/Bullet_Marker.global_position.direction_to(get_global_mouse_position()))

func alt_attack():
	Animations.shakeCam($Camera2D, 1.5)
	$Sprite/Arrows.visible = false

	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(false)
	tween.tween_property($Sprite/Body, "position", Vector2(0, -50.0), 0.03)
	tween.tween_property($Sprite/Head, "position", Vector2(-2, -66.5), 0.1)
	tween.tween_property($Sprite/Body, "position", Vector2(0, -40.0), 0.1)
	tween.tween_property($Sprite/Head, "position", Vector2(-2, -60.5), 0.1)
	
	if items.has("shovel"):
		var tp_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(false)
		tp_tween.tween_property($Sprite, "scale", Vector2(0, 0), 0.2)
		tp_tween.tween_property($Sprite, "scale", Vector2(1, 1), 0.2)
		await get_tree().create_timer(0.2).timeout
		global_position = get_global_mouse_position()
		
	if items.has("nest"):
		var num_bullets := 8  # сколько пуль выпускаем (8 = полный круг)
		for i in num_bullets:
			var angle = deg_to_rad(360.0 / num_bullets * i)
			var dir = Vector2.RIGHT.rotated(angle)
			G.spawn_bullet(self, bullet_scene, $Gun/Bullet_Marker.global_position, dir)
		
func special_attack():
	if special_attack_charge >= special_attack_cost:
		Animations.shakeCam($Camera2D, 3)
		$Sprite/Arrows.visible = false
		
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(false)
		tween.tween_property($Sprite/Body, "position", Vector2(0, -50.0), 0.03)
		tween.tween_property($Sprite/Head, "position", Vector2(-2, -66.5), 0.1)
		tween.tween_property($Sprite/Body, "position", Vector2(0, -40.0), 0.1)
		tween.tween_property($Sprite/Head, "position", Vector2(-2, -60.5), 0.1)

		special_attack_charge = 0
		$CanvasLayer/SpecialAttack.value = special_attack_charge

		var num_bullets := 16  # сколько пуль выпускаем (8 = полный круг)
		for i in num_bullets:
			var angle = deg_to_rad(360.0 / num_bullets * i)
			var dir = Vector2.RIGHT.rotated(angle)
			G.spawn_bullet(self, bullet_scene, $Gun/Bullet_Marker.global_position, dir, true)
			Animations.shakeCam($Camera2D, 2)
			await get_tree().create_timer(0.05).timeout
	
func shakeLoop():
	if !is_shaking:
		is_shaking=true
		while is_charging_jump: 
			if charge_timer == 1:
				Animations.flash(self,1.2)
			$Sprite.scale = Vector2(1-charge_timer/15, 1-charge_timer/10)
			var hurtTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE).set_parallel(false)
			hurtTween.tween_property($Sprite, "rotation", charge_timer/15, 0.05)
			hurtTween.tween_property($Sprite, "rotation", -charge_timer/15, 0.05)
			hurtTween.tween_property($Sprite, "rotation", 0, 0.1)
			await get_tree().create_timer(0.1).timeout
			$Sprite.rotation = 0
			Animations.shakeCam($Camera2D, 0.1)
		is_shaking = false
		$Sprite.scale = Vector2.ONE

func on_bullet_land(_bullet):
	special_attack_charge += 8
	$CanvasLayer/SpecialAttack.value = special_attack_charge
	
func add_item(table, item_id: String):
	if ["candles",].has(item_id):
		if active_item == "":
			table.queue_free()
		table.setItem(active_item)
		active_item = item_id
		$CanvasLayer/SpecialAttackIcon.texture = load("res://Assets/Textures/Items/item_" + item_id + ".png")
	else:
		items.append(item_id)
		update_items()
		table.queue_free()
	
	match item_id:
		"candy_corn":
			max_health+=1
			health+=1
			update_health()
		"shovel":
			$AltAttackCD.wait_time += 2.5
		"nest":
			$AltAttackCD.wait_time += 0.5
	
func update_items():
	for i in $CanvasLayer/Items.get_children():
		i.queue_free()
	for i in items:
		var item_icon = load("res://Scenes/item_button.tscn").instantiate()
		item_icon.item = i
		$CanvasLayer/Items.add_child(item_icon)
	
func update_health():
	for h in $CanvasLayer/Health.get_children():
		h.queue_free()
	for h in health:
		var health_container = TextureRect.new()
		health_container.texture = load("res://Assets/UI/health.png")
		$CanvasLayer/Health.add_child(health_container)

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body is Tile:
		die()

func take_damage(dmg):
	health -= dmg
	Animations.shakeCam($Camera2D, 3)
	await Animations.flash(self,5)
	update_health()
	if health <= 0:
		die()
		
func die():
	can_move = false
	can_take_damage = false
	
	$Sprite/Arrows.visible = false
	$Sprite/Shadow.visible = false
	
	await get_tree().create_timer(0.3).timeout
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)
	tween.tween_property($Camera2D, "zoom", Vector2(2,2), 0.5)
	
	await get_tree().create_timer(0.4).timeout
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)
	tween.tween_property(self, "position", global_position + Vector2(0, 100.0), 0.3)
	tween.tween_property($Sprite/Head.material, "shader_parameter/dissolve_value", 0, 2.0)

	await get_tree().create_timer(1.0).timeout
	await Animations.disappear(G.main)
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_attack_cd_timeout() -> void:
	pass # Replace with function body.

func _on_alt_attack_cd_timeout() -> void:
	$Sprite/Head.texture = load("res://Assets/Textures/character2_active.png")
