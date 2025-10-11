extends Sprite2D

var lifetime: float = 1.0
var blinks: int = 4

func _ready() -> void:
	for i in blinks:
		await Animations.appear(self,0.05)
		await get_tree().create_timer(lifetime/blinks - 0.1).timeout
		await Animations.disappear(self,0.05)
	queue_free()
