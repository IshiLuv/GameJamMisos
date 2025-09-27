extends CharacterBody2D
class_name Entity

@export var max_health: int = 10
var health: int = max_health

func take_damage(dmg):
	await Animations.flash(self,5)
	health -= dmg
	if health <= 0:
		die()
		
func die():
	queue_free()
