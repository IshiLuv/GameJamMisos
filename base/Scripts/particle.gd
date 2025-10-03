extends CPUParticles2D

func play():
	restart()

func _on_finished() -> void:
	queue_free()
