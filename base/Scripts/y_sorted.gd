extends Sprite2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body and (body is Player or body is Enemy):
		if body.global_position.y < global_position.y:
			z_index = 300
		else:
			z_index = 5


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body and (body is Player or body is Enemy):
		if body.global_position.y < global_position.y:
			z_index = 300
		else:
			z_index = 5
