extends Control

var _t = 0

func _ready() -> void:
	$Panel/VBoxContainer/Play.pressed.connect(_play)
	$Panel/VBoxContainer/Credits.pressed.connect(_credit)
	
func _play() -> void:
	Clicks.play(0.4)
	Game.start_run()
	Flow.goto("res://hub/hub.tscn")

func _credit() -> void:
	Clicks.play(0.4)

func _process(delta: float) -> void:
	_t += delta
	$Title.add_theme_color_override("font_outline_color", Color(1.6, 0.5, 0.9).lerp(Color(0.9, 0.4, 1.6), sin(_t) * 0.5 + 0.5))
