extends Entity
class_name Player

var speed: float = 200.0
var min_jump_force: float = 400.0
var max_jump_force: float = 900.0
var max_charge_time: float = 0.5
var charge_timer: float = 0.0
var jump_timer: float = 0.0

var camera_zoom: Vector2 = Vector2(1.2,1.2)

var bullet_scene = preload("res://Scenes/Bullets/bullet_player.tscn")

var items: Array = []
var active_item: String = ""

var enemies_on_mouse: Array = []

var input_dir: Vector2
var jump_velocity: Vector2
var jump_target: Vector2 = Vector2.ZERO

var special_attack_cost: int = 100
var special_attack_charge: int = 0

var is_jumping: bool = false
var is_charging_jump: bool = false
var is_shaking: bool = false
var can_move: bool = true
var can_take_damage: bool = true

var bullet_damage_mult: float = 1.0
var bullet_damage: int = 1
var bullets_count: int = 1
var fire_duration: int = 2

var on_ground: bool = true
var pre_jump_pos: Vector2

func _ready() -> void:
	can_move = false
	$CanvasLayer/Restart.visible = true
	await get_tree().create_timer(0.5).timeout
	Animations.disappear($CanvasLayer/Restart)
	$Sprite/Head.material.set_shader_parameter("dissolve_value", 1.0)
	health = max_health
	update_health()
	$CanvasLayer/AttackCD.text = "Attack Cooldown: %s" % $AttackCD.wait_time
	$CanvasLayer/AltAttackCD.text = "Alt Attack Cooldown: %s" % $AltAttackCD.wait_time
	$CanvasLayer/BulletDamage.text = "Bullet damage: %s" % bullet_damage
	$CanvasLayer/DamageMult.text = "Damage mult: %s" % bullet_damage_mult
	$Camera2D.zoom = camera_zoom
	if !G.watchedCutscene2:
		await get_tree().create_timer(10.5).timeout
	$Camera2D.enabled = true
	$ArrowsMarker/Arrows.visible = true
	can_move = true
	
func _process(delta: float) -> void:
	$MouseArea.global_position = get_global_mouse_position()
	
	if $HurtCD.time_left > 0 and int($HurtCD.time_left*10) % 2 == 0:
		Animations.flash(self,-5)
	
	if can_move:
		if G.isGridMove:
			input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		else:
			input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()


		if input_dir != Vector2.ZERO and !is_jumping:
			if G.isGridMove:
				var tiles_to_jump =  int(ceil(lerp((min_jump_force+1), max_jump_force, charge_timer / max_charge_time)/250))
				var target_offset = input_dir * tiles_to_jump * Vector2(64,48)
				jump_target = (global_position.snapped(Vector2(64,48)) + target_offset).snapped(Vector2(64,48))
				
			var arrow_dir = input_dir*60
			if G.showLand: 
				arrow_dir = input_dir*(lerp(min_jump_force, max_jump_force, charge_timer / max_charge_time) + int(charge_timer==max_charge_time)*100)/4
				if G.isGridMove: 
					arrow_dir = jump_target - global_position

			$ArrowsMarker.rotation = arrow_dir.angle()
			$ArrowsMarker.visible = true
			$ArrowsMarker/Arrows.scale.x = arrow_dir.length() / 36.0
		else:
			$ArrowsMarker.rotation = 0
			$ArrowsMarker.visible = false
		
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
			charge_timer = min(charge_timer + delta, max_charge_time)
			shakeLoop()

		if Input.is_action_just_released("jump") and is_charging_jump and !is_jumping:
			start_jump()
		
		if Input.is_action_pressed("shift") and !is_jumping:
			min_jump_force = 70.0 
			max_jump_force = 400.0
			if !G.showLand: $ArrowsMarker/Arrows.scale.x = 1
			
		if Input.is_action_just_released("shift"):
			min_jump_force = 400.0 + items.count("pogo")*200
			max_jump_force = 900.0 + items.count("pogo")*200
			
		if Input.is_action_just_released("pause"):
			get_tree().paused = true
			var pause_menu = load("res://Scenes/settings_menu.tscn").instantiate()
			pause_menu.set_anchors_preset(Control.PRESET_CENTER, false)
			$CanvasLayer.add_child(pause_menu)
			
		if Input.is_action_just_released("green_screen"):
			if $ColorRect.visible:
				Animations.disappear($ColorRect,5) 
			else:
				Animations.appear($ColorRect,5) 

func _physics_process(delta: float) -> void:
	if can_move and is_jumping:
		if !G.isGridMove:
			var air_control = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
			if air_control != Vector2.ZERO:
				jump_velocity = lerp(jump_velocity, air_control * jump_velocity.length(), 0.1)
		
		velocity = jump_velocity
		jump_timer -= delta
		if jump_timer <= 0.0:
			is_jumping = false
			can_take_damage = true
			$ArrowsMarker/Arrows.visible = true
			velocity = Vector2.ZERO
			$Hurtbox/CollisionShape2D.disabled = false
			await get_tree().physics_frame
			if !on_ground:
				fall()
				return
			
			if G.isGridMove: global_position = global_position.snapped(Vector2(64,48))
			
			Animations.shakeCam($Camera2D, 0.4)
			Sounds.play_sound(global_position,"stick"+str(randi_range(1,5)), -3.0, "SFX", 0.1, 1.0)

	move_and_slide()
	
func start_jump():
	pre_jump_pos = global_position
	is_charging_jump = false
	is_jumping = true
	on_ground = false
	$Hurtbox/CollisionShape2D.disabled = true
	if items.has("spring"): can_take_damage = false
	
	jump()
	
	var force = lerp(min_jump_force, max_jump_force, charge_timer / max_charge_time) + int(charge_timer==max_charge_time)*100
	
	if G.isGridMove:
		jump_timer = 0.2 + items.count("wings")/2.0
		jump_velocity = (jump_target - global_position) / jump_timer
	else: 
		jump_timer = 0.2 + force/17000 + items.count("wings")/2.0
		jump_velocity = input_dir * force
	
	charge_timer = 0.0

func jump():
	Sounds.play_sound(global_position,"stick"+str(randi_range(1,5)), -15.0, "SFX", 0.1, 1.5)
	Animations.shakeCam($Camera2D, 0.5)
	$ArrowsMarker/Arrows.visible = false
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(false)
	tween.tween_property($Sprite/Body, "position", Vector2(0, -50.0-charge_timer*20), 0.05)
	tween.tween_property($Sprite/Head, "position", Vector2(-2, -66.5-charge_timer*10), 0.1)
	tween.tween_property($Sprite/Body, "position", Vector2(0, -40.0), 0.1)
	tween.tween_property($Sprite/Head, "position", Vector2(-2, -60.5), 0.1)

func attack():
	Animations.shakeCam($Camera2D, 1)
	$ArrowsMarker/Arrows.visible = false
	
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(false)
	tween.tween_property($Sprite/Body, "position", Vector2(0, -50.0), 0.03)
	tween.tween_property($Sprite/Head, "position", Vector2(-2, -66.5), 0.1)
	tween.tween_property($Sprite/Body, "position", Vector2(0, -40.0), 0.1)
	tween.tween_property($Sprite/Head, "position", Vector2(-2, -60.5), 0.1)
	
	if active_item == "staff":
		var bullet = load("res://Scenes/Bullets/bullet_melee.tscn").instantiate()
		bullet.global_position = $Gun/Bullet_Marker.global_position
		bullet.direction = $Gun/Bullet_Marker.global_position.direction_to(get_global_mouse_position())
		bullet.look_at(get_global_mouse_position())
		bullet.sender = self
		bullet.damage = bullet_damage+1
		bullet.is_burning = items.has("match")
		bullet.do_flip = false
		G.main.add_child(bullet)
		await get_tree().create_timer(0.1).timeout
		if bullet: bullet.queue_free()
	else:
		for i in bullets_count:
			Sounds.play_sound(global_position,"gg_attack"+str(randi_range(1,3)), -2.0, "SFX", 0.1, 1.0)
			G.spawn_bullet(self, bullet_scene, $Gun/Bullet_Marker.global_position, $Gun/Bullet_Marker.global_position.direction_to(get_global_mouse_position()), bullet_damage, items.has("match"), items.has("bird_amulet"))
			await get_tree().create_timer(0.2).timeout
			
func alt_attack():
	Animations.shakeCam($Camera2D, 1.5)
	$ArrowsMarker/Arrows.visible = false

	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(false)
	tween.tween_property($Sprite/Body, "position", Vector2(0, -50.0), 0.03)
	tween.tween_property($Sprite/Head, "position", Vector2(-2, -66.5), 0.1)
	tween.tween_property($Sprite/Body, "position", Vector2(0, -40.0), 0.1)
	tween.tween_property($Sprite/Head, "position", Vector2(-2, -60.5), 0.1)
	
	if items.has("shovel"):
		Sounds.play_sound(global_position,"gg_digging", 0.0, "SFX", 0.0, 1.0)
		var tp_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(false)
		tp_tween.tween_property($Sprite, "scale", Vector2(0, 0), 0.2)
		tp_tween.tween_property($Sprite, "scale", Vector2(1, 1), 0.2)
		await get_tree().create_timer(0.2).timeout
		global_position = get_global_mouse_position()
		
	if items.has("nest"):
		Sounds.play_sound(global_position,"gg_attack"+str(randi_range(1,3)), -3.0, "SFX", 0.1, 1.0)
		var num_bullets := 8  # сколько пуль выпускаем (8 = полный круг)
		for i in num_bullets:
			var angle = deg_to_rad(360.0 / num_bullets * i)
			var dir = Vector2.RIGHT.rotated(angle)
			G.spawn_bullet(self, bullet_scene, $Gun/Bullet_Marker.global_position, dir, bullet_damage, items.has("match"), items.has("bird_amulet"))
	else:
		var num_bullets := 3  # сколько пуль выпускаем (8 = полный круг)
		for i in num_bullets:
			Sounds.play_sound(global_position,"gg_attack"+str(randi_range(1,3)), -4.0, "SFX", 0.1, 1.0)
			G.spawn_bullet(self, bullet_scene, $Gun/Bullet_Marker.global_position, $Gun/Bullet_Marker.global_position.direction_to(get_global_mouse_position()), bullet_damage, items.has("match"), items.has("bird_amulet"))
			await get_tree().create_timer(0.2).timeout
	
func special_attack():
	if special_attack_charge >= special_attack_cost:
		Sounds.play_sound(global_position,"gg_special_attack", -0.0, "SFX", 0.4, 2.0)
		Animations.shakeCam($Camera2D, 3)
		$ArrowsMarker/Arrows.visible = false
		
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(false)
		tween.tween_property($Sprite/Body, "position", Vector2(0, -50.0), 0.03)
		tween.tween_property($Sprite/Head, "position", Vector2(-2, -66.5), 0.1)
		tween.tween_property($Sprite/Body, "position", Vector2(0, -40.0), 0.1)
		tween.tween_property($Sprite/Head, "position", Vector2(-2, -60.5), 0.1)

		special_attack_charge = 0
		$CanvasLayer/SpecialAttack.value = special_attack_charge

		match active_item:
			"candles":
				can_take_damage = false
				
				var num_bullets := 16  # сколько пуль выпускаем (8 = полный круг)
				for i in num_bullets:
					var angle = deg_to_rad(360.0 / num_bullets * i)
					var dir = Vector2.RIGHT.rotated(angle)
					
					G.spawn_bullet(self, bullet_scene, $Gun/Bullet_Marker.global_position, dir, bullet_damage, true, items.has("bird_amulet"))

					Animations.shakeCam($Camera2D, 2)
					await get_tree().create_timer(0.05).timeout
					
				can_take_damage = true
			"witch_hat":
				if !await heal(1):
					special_attack_charge = 100
					$CanvasLayer/SpecialAttack.value = special_attack_charge
			"chef_hat":
				var bullet = load("res://Scenes/Bullets/bullet_knife.tscn").instantiate()
				bullet.global_position = $Gun/Bullet_Marker.global_position
				bullet.direction = $Gun/Bullet_Marker.global_position.direction_to(get_global_mouse_position())
				bullet.sender = self
				bullet.damage = bullet_damage+1
				bullet.is_burning = items.has("match")
				bullet.speed = 400
				bullet.is_spinning = true
				bullet.damage = 10
				bullet.is_autoaim = items.has("bird_amulet")
				G.main.add_child(bullet)
			"staff":
				Sounds.play_sound(global_position, "royal", -1.0, "SFX", 0.4, 1.0)

				var royal = load("res://Scenes/royal.tscn").instantiate()
				get_tree().get_root().add_child(royal)
				
				royal.global_position = get_global_mouse_position()+Vector2(0,-1000)
				
				var target_highlight = load("res://Scenes/target_highlight.tscn").instantiate()
				target_highlight.scale = Vector2(2,2)
				get_tree().get_root().add_child(target_highlight)
				target_highlight.global_position = get_global_mouse_position()
				
				await get_tree().create_timer(0.6).timeout
				
				var royal_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(false)
				royal_tween.tween_property(royal, "global_position", royal.global_position + Vector2(0,990), 0.4)
				
				await get_tree().create_timer(0.35).timeout
				Sounds.play_sound(global_position, "royal_land", -1.0, "SFX", 0.4, 1.0)
				royal.get_node("Area2D").monitoring = true
				await get_tree().create_timer(0.4).timeout
				if royal: royal.queue_free()

			_:
				for i in 3:
					var bullet = load("res://Scenes/Bullets/bullet_witch.tscn").instantiate()
					bullet.global_position = $Gun/Bullet_Marker.global_position
					bullet.direction = $Gun/Bullet_Marker.global_position.direction_to(get_global_mouse_position())
					bullet.sender = self
					bullet.damage = bullet_damage
					bullet.is_burning = items.has("match")
					bullet.damage = 2
					bullet.is_autoaim = items.has("bird_amulet")
					G.main.add_child(bullet)
					await get_tree().create_timer(0.1).timeout
		
func shakeLoop():
	
	if !is_shaking:
		var sound = Sounds.play_sound(global_position,"titiva_start", -15.0, "SFX", 0.9, 0.4)
		is_shaking=true
		while is_charging_jump: 
			if charge_timer >= max_charge_time:
				Animations.flash(self,1.2)
			$Sprite.scale = Vector2(1-charge_timer/10, 1-charge_timer/5)
			$Camera2D.zoom = camera_zoom/(1+charge_timer/20)
			await get_tree().create_timer(0.05).timeout
			$Sprite.scale = Vector2(1-charge_timer/10, 1-charge_timer/5)
			$Camera2D.zoom = camera_zoom/(1+charge_timer/20)
			var hurtTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE).set_parallel(false)
			hurtTween.tween_property($Sprite, "rotation", charge_timer/6, 0.05)
			hurtTween.tween_property($Sprite, "rotation", -charge_timer/6, 0.05)
			hurtTween.tween_property($Sprite, "rotation", 0, 0.1)
			await get_tree().create_timer(0.05).timeout
			$Sprite.rotation = 0
			
			Animations.shakeCam($Camera2D, 0.1)
			Sounds.play_sound(global_position,"titiva_loop", -12.0, "SFX", 0.3, 1.2)
		is_shaking = false
		if sound: sound.stop()
		$Sprite.scale = Vector2.ONE
		$Camera2D.zoom = camera_zoom

func on_bullet_land(_bullet):
	if items.has("blood") and randf()>(1 - 0.05*items.count("blood")):
		heal(1)
	if special_attack_charge < special_attack_cost:
		special_attack_charge += abs(8-(items.count("witch_hat")))
		$CanvasLayer/SpecialAttack.value = special_attack_charge
		if special_attack_charge >= special_attack_cost:
			Sounds.play_sound(global_position,"altushka", -3.0, "SFX", 0.4, 0.5)
	
func add_item(table, item_id: String):
	if ["candles","chef_hat","witch_hat","staff",].has(item_id):
		if active_item == "":
			table.queue_free()
		table.setItem(active_item)
		active_item = item_id
		$CanvasLayer/SpecialAttackButton.item = item_id
		$CanvasLayer/SpecialAttackButton._ready()
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
			$CanvasLayer/AltAttackCD.text = "Alt Attack Cooldown: %s" % $AltAttackCD.wait_time
		"nest":
			bullets_count+=1
			$AltAttackCD.wait_time /= 1.5
			$CanvasLayer/AltAttackCD.text = "Alt Attack Cooldown: %s" % $AltAttackCD.wait_time
		"clock":
			$AltAttackCD.wait_time /= 2.0
			$CanvasLayer/AltAttackCD.text = "Alt Attack Cooldown: %s" % $AltAttackCD.wait_time
		"clock2":
			$AttackCD.wait_time /= 2.0
			$CanvasLayer/AttackCD.text = "Attack Cooldown: %s" % $AttackCD.wait_time
		"bird_protein":
			bullet_damage += 1
			$CanvasLayer/BulletDamage.text = "Bullet damage: %s" % bullet_damage
		"lamp":
			bullet_damage_mult += 0.3
			$CanvasLayer/DamageMult.text = "Damage mult: %s" % bullet_damage_mult
		"pogo":
			max_jump_force += 200
		"match":
			fire_duration += 1
		"spring":
			max_charge_time += 0.8
		"hat":
			can_take_damage = false
			var hat_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)
			hat_tween.tween_property($Camera2D, "zoom", Vector2(2,2), 0.5)
			
			await get_tree().create_timer(0.6).timeout
			await Animations.disappear(G.main)
			get_tree().change_scene_to_file("res://Scenes/final.tscn")
		
	var popup = load("res://Scenes/item_popup.tscn").instantiate()
	popup.item = item_id
	$CanvasLayer/ItemPopups.add_child(popup)
	popup.position = Vector2(-100, 0.0)
	var tween_popup = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(false)
	tween_popup.tween_property(popup, "position", Vector2(50, 0.0), 0.2)
	tween_popup.tween_property(popup, "position", Vector2(50, 0.0), 1.3)
	tween_popup.tween_property(popup, "position", Vector2(-300, 0.0), 0.2)
	await tween_popup.finished
	popup.queue_free()
			
	
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
		on_ground = true

func fall():
	
	if !$Hurtbox/CollisionShape2D.disabled:
		$Hurtbox/CollisionShape2D.disabled = true
		velocity = Vector2.ZERO
		can_move = false
		can_take_damage = false
		
		$ArrowsMarker/Arrows.visible = false
		$Sprite/Shadow.visible = false

		await get_tree().create_timer(0.2).timeout
		Sounds.play_sound(global_position,"gg_fell_in_lava", -3.0, "SFX", 0, 1)
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)
		tween.tween_property($Camera2D, "zoom", Vector2(2,2), 0.5)

		await get_tree().create_timer(0.4).timeout
		
		$HurtCD.start()
		health -= 1
		if health <= 0:
			Sounds.play_sound(global_position,"gg_death", -3.0, "SFX", 0, 1)
		else:
			Sounds.play_sound(global_position,"gg_hit", -0.0, "SFX", 0.4, 2.0)
		Animations.shakeCam($Camera2D, 3)
		await Animations.flash(self,5)
		update_health()
		
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)
		tween.tween_property(self, "position", global_position + Vector2(0, 100.0), 0.3)
		tween.tween_property($Camera2D, "zoom", Vector2(1.2,1.2), 0.5)
		tween.tween_property($Sprite/Head.material, "shader_parameter/dissolve_value", 0, 1.0)
		tween.set_parallel(false)
		
		if health <= 0:
			die()
			return

		tween.tween_property($Sprite/Head.material, "shader_parameter/dissolve_value", 1, 0.4)
		
		await get_tree().create_timer(1.0).timeout
			
		global_position = pre_jump_pos
		
		can_take_damage = true
		can_move = true
		$ArrowsMarker/Arrows.visible = true
		$Sprite/Shadow.visible = true
		$Hurtbox/CollisionShape2D.disabled = false
	
func take_damage(dmg):
	if $HurtCD.is_stopped() and can_take_damage:
		$HurtCD.start()
		can_take_damage = false
		
		health -= dmg
		
		if health <= 0:
			Sounds.play_sound(global_position,"gg_death", -3.0, "SFX", 0, 1)
		else:
			Sounds.play_sound(global_position,"gg_hit", -0.0, "SFX", 0.4, 2.0)
			
		Animations.shakeCam($Camera2D, 5)
		await Animations.flash(self,5)
		update_health()
		if health <= 0:
			die()
		
func die():
	velocity = Vector2.ZERO
	can_move = false
	can_take_damage = false
	
	$CollisionShape2D.disabled = true
	$Hurtbox.monitorable = false
	
	$ArrowsMarker/Arrows.visible = false
	$Sprite/Shadow.visible = false
	
	
	await get_tree().create_timer(0.3).timeout

	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)
	tween.tween_property($Camera2D, "zoom", Vector2(2,2), 0.5)
	
	await get_tree().create_timer(0.4).timeout
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)

	tween.tween_property($Sprite/Head.material, "shader_parameter/dissolve_value", 0, 2.0)
	
	Animations.appear($CanvasLayer/Restart)
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func heal(hp):
	if health<max_health:
		health += hp
		Sounds.play_sound(global_position,"altushka", -1.0, "SFX", 0.4, 3.0)
		Animations.shakeCam($Camera2D, 3)
		await Animations.flash(self,5)
		update_health()
		return true
	else: return false

func _on_attack_cd_timeout() -> void:
	pass # Replace with function body.

func _on_alt_attack_cd_timeout() -> void:
	$Sprite/Head.texture = load("res://Assets/Textures/character2_active.png")
	Sounds.play_sound(global_position,"altushka", -5.0, "SFX", 0.4, 1.5)
	Animations.flash(self,1.2)

func _on_hurt_cd_timeout() -> void:
	can_take_damage = true


func _on_mouse_area_body_entered(body: Node2D) -> void:
	if body and body is Enemy:
		enemies_on_mouse.append(body)


func _on_mouse_area_body_exited(body: Node2D) -> void:
	if body and body is Enemy:
		enemies_on_mouse.erase(body)
