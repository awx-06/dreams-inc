class_name ClientCard
extends PanelContainer

@onready var name_label: Label = $MarginContainer/VBoxContainer/Name
@onready var problem_label: Label = $MarginContainer/VBoxContainer/Problem
@onready var meta_label: Label = $MarginContainer/VBoxContainer/Meta
@onready var take_button: Button = $MarginContainer/VBoxContainer/Take

var client_index := -1

func setup(i: int) -> void:
	client_index = i
	var c: Dictionary = Game.CLIENTS[i]
	name_label.text = c.name
	problem_label.text = c.problem
	meta_label.text = "Lv %d — ✦%d" % [c.level, c.reward]
	take_button.pressed.connect(_take)

func _take() -> void:
	Clicks.play(0.3)
	Game.current_client = client_index
	Flow.goto(Game.CLIENTS[client_index].scene)
