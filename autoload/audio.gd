extends Node

var music_player: AudioStreamPlayer

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)

func play_music(stream: AudioStream) -> void:
	if music_player.stream == stream and music_player.playing:
		return
	music_player.stream = stream
	music_player.play()

func sfx(stream: AudioStream, pitch_var := 0.0) -> void:
	if stream == null:
		return
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.bus = "SFX"
	p.pitch_scale = 1.0 + randf_range(-pitch_var, pitch_var)
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()
