extends TextureButton

@export var hover_scale: Vector2 = Vector2(1.2, 1.2)
@export var animate_time: float = 0.2

func _ready():
	pivot_offset = size * 0.5
	connect("resized", Callable(self, "_update_pivot"))
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited",  Callable(self, "_on_mouse_exited"))
	connect("pressed", Callable(self, "_on_pressed"))
func _update_pivot():
	pivot_offset = size * 0.5
	
func _on_mouse_entered():
	_animate_scale(hover_scale)

func _on_mouse_exited():
	_animate_scale(Vector2.ONE)
	
func _animate_scale(target_scale: Vector2) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", target_scale, animate_time) \
		 .set_trans(Tween.TRANS_QUAD) \
		 .set_ease(Tween.EASE_OUT)
