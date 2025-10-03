extends Node2D

func _ready() -> void:
	$Music.play()

func stop_music():
	$Music.stop()

func set_music(sound_name: String):
	$Music.stream = load("res://Assets/Sounds/" + sound_name + ".ogg")
	$Music.play()
	
func play_sound(pos: Vector2, sound_name: String, volume: float = 0.0, bus: String = "Master", pitch_offset: float = 0.0, pitch: float = 1.0):
	sound_name = "res://Assets/Sounds/" + sound_name + ".ogg"
	var new_audio: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(new_audio)
	new_audio.bus = bus
	new_audio.stream = load(sound_name)
	new_audio.volume_db = volume - pos.distance_to(G.main.player.global_position)/300
	if pitch_offset != 0.0:
		pitch += randf_range(-pitch_offset, pitch_offset)
	new_audio.pitch_scale = abs(pitch)
	new_audio.play()
	delete_sound(new_audio)
	return new_audio
	
func delete_sound(sound):
	await get_tree().create_timer(sound.stream.get_length() + 0.7).timeout 
	sound.queue_free()
