extends Node

func appear(obj: Object, time: float = 1):
	obj.visible = true
	obj.modulate[3] = 0
	create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel(false).tween_property(obj, "modulate:a", 1, time)

func disappear(obj: Object, time: float = 1):
	create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel(false).tween_property(obj, "modulate:a", 0, time)
	await get_tree().create_timer(time).timeout
	obj.visible = false
