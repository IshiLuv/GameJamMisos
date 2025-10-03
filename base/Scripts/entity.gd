extends CharacterBody2D
class_name Entity

@export var max_health: int = 10
var health: int = max_health

var is_burning: bool = false

var is_dying: bool = false

func take_damage(dmg):
	if self is Enemy:
		Sounds.play_sound(global_position,"enemy_hurt", -13.0, "SFX", 0.0, 0.7)
	
	await Animations.flash(self,8)
	health -= dmg
	await get_tree().create_timer(0.1).timeout
	if health <= 0:
		die()

func die():
	if !is_dying:
		is_dying = true
		await Animations.flash(self,15)
		if self is Enemy:
			Sounds.play_sound(global_position,"enemy_died"+str(randi_range(1,3)), 0.0, "SFX", 0.0, 1.0)
			var texture = AtlasTexture.new()
			if $Sprite2D:
				texture.atlas = $Sprite2D.texture
				$DeathParticle.texture = texture
				$DeathParticle.texture.region = Rect2(texture.atlas.get_width()/2/$Sprite2D.hframes-5,texture.atlas.get_height()/2/$Sprite2D.hframes-5,texture.atlas.get_width()/2/$Sprite2D.hframes+5,texture.atlas.get_height()/2/$Sprite2D.hframes+5)
			$DeathParticle.play()
			$DeathParticle.reparent(get_tree().get_root())
		Animations.jump(self,Tween.TransitionType.TRANS_BACK)
		await get_tree().create_timer(0.1).timeout
		queue_free()

func set_burning():
	$BurnParticle.emitting = true
	is_burning = true
	burn()
	await get_tree().create_timer(G.main.player.fire_duration).timeout
	$BurnParticle.emitting = false
	is_burning = false

func burn():
	while is_burning:
		await get_tree().create_timer(1.0).timeout
		take_damage(1)
		
