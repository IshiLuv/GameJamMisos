extends Node

func appear(obj: Object, time: float = 1):
	obj.visible = true
	obj.modulate[3] = 0
	create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(false).tween_property(obj, "modulate:a", 1, time)

func disappear(obj: Object, time: float = 1):
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(false)
	tween.tween_property(obj, "modulate:a", 0, time)
	await get_tree().create_timer(time).timeout
	if obj: obj.visible = false
	
func blink(obj: Object, time: float = randf()/10):
	for i in 6:
		if obj: obj.visible = !obj.visible
		await get_tree().create_timer(time).timeout

func flash(obj, power: float): 
	obj.modulate = Color(power,power,power)
	await get_tree().create_timer(0.03).timeout
	if obj: obj.modulate = Color(1,1,1)

func jump(obj: Object, tween_trans: Tween.TransitionType = Tween.TRANS_SINE, 
scale_1: Array = [Vector2(1.1,1.1), 0.1], 
scale_2: Array = [Vector2(1.0,1.0), 0.1]):
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(tween_trans)
	tween.tween_property(obj, "scale", scale_1[0], scale_1[1])
	tween.tween_property(obj, "scale", scale_2[0], scale_2[1])
	
func drop(obj: Object, scale: Array = [Vector2(1.0,1.0), 0.1], trans: Tween.TransitionType = Tween.TRANS_BOUNCE):
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(trans)
	tween.tween_property(obj, "rotation_degrees", -5, 0.05)
	tween.tween_property(obj, "rotation_degrees", 3, 0.01)
	tween.tween_property(obj, "rotation_degrees", 0, 0.1)
	tween.set_parallel(true)
	tween.tween_property(obj, "scale", scale[0], scale[1])

func shakeCam(cam: Camera2D, power: float = 0.5, duration: float = 0.05, shakes: int = 2):
	if not cam: return

	var original_offset = cam.offset
	var tween = create_tween().set_parallel(false)
	
	for i in range(shakes):
		var random_offset := Vector2(randf_range(-power*10, power*10),randf_range(-power*10, power*10))
		tween.tween_property(cam, "offset", random_offset, duration / (shakes * 2))
		tween.tween_property(cam, "offset", original_offset, duration / (shakes * 2))
		
	await get_tree().create_timer(shakes*duration).timeout
	if cam: cam.offset = original_offset
	
func shake(obj: Object, power):
	var hurtTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE).set_parallel(false)
	hurtTween.tween_property(obj, "rotation", power/2, 0.05)
	hurtTween.tween_property(obj, "rotation", -power, 0.05)
	hurtTween.tween_property(obj, "rotation", 0, 0.1)
	await get_tree().create_timer(0.5).timeout
	obj.rotation = 0
