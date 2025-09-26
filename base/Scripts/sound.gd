extends Node2D

func create_audio(sound_name: String, volume: float = 0.0, pitch_offset: float = 0.0, pitch: float = 1.0) -> void:
	sound_name = "res://Assets/Sounds/" + sound_name + ".ogg"
	var new_audio: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(new_audio)
	new_audio.stream = load(sound_name)
	new_audio.volume_db = volume
	new_audio.pitch_scale = pitch
	if pitch_offset != 0.0:
		new_audio.pitch_scale += randf_range(-pitch_offset, pitch_offset)
	new_audio.play()
	await get_tree().create_timer(new_audio.stream.get_length() + 0.1).timeout 
	new_audio.queue_free()
