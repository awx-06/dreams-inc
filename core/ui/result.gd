extends Control

@onready var title_label: Label = $PanelContainer/VBoxContainer/Title
@onready var body_label: Label = $PanelContainer/VBoxContainer/Body

func _ready() -> void:
	var r: Dictionary = Game.last_result
	if Game.hearts <= 0:
		title_label.text = "YOU WOKE UP"
		body_label.text = "Repaired %d · ✦%d" % [Game.repaired_count, Game.money]
		$PanelContainer/VBoxContainer/Back.text = "TRY AGAIN"
		$PanelContainer/VBoxContainer/Back.pressed.connect(_back)
		return
	if r.get("won", false):
		title_label.text = "DREAM REPAIRED"
		body_label.text = "✦%d earned" % r.get("reward", 0)
	else:
		title_label.text = "EJECTED"
		body_label.text = "The dream ran out." if r.get("reason") == "time" else "It caught you. ♥ -1"
	$PanelContainer/VBoxContainer/Back.pressed.connect(_back)

func _back() -> void:
	Clicks.play(0.3)
	if Game.hearts <= 0:
		Flow.goto("res://hub/title.tscn")   # stub — hub for now if no title
	else:
		Flow.goto("res://hub/hub.tscn")
