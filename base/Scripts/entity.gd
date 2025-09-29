extends CharacterBody2D
class_name Entity

@export var max_health: int = 10
var health: int = max_health

var is_burning: bool = false

var is_dying: bool = false

func take_damage(dmg):
	if self is Enemy:
		Sounds.play_sound(global_position,"enemy_hurt", -6.0, "SFX", 0.0, 1.0)
	
	await Animations.flash(self,5)
	health -= dmg
	await get_tree().create_timer(0.1).timeout
	if health <= 0:
		die()

func die():
	if !is_dying:
		is_dying = true
		if self is Enemy:
			Sounds.play_sound(global_position,"enemy_died"+str(randi_range(1,3)), 0.0, "SFX", 0.0, 1.0)
		await get_tree().create_timer(0.1).timeout
		queue_free()

func set_burning():
	$BurnParticle.emitting = true
	is_burning = true
	burn()
	await get_tree().create_timer(2.0).timeout
	$BurnParticle.emitting = false
	is_burning = false

func burn():
	while is_burning:
		await get_tree().create_timer(1.0).timeout
		take_damage(1)
		
