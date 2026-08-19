extends CanvasLayer

signal finished(success: bool)
signal solved_one
signal mistake

const GLYPH := { "U": "↑", "D": "↓", "L": "←", "R": "→" }
const ACTION := { "move_up": "U", "move_down": "D", "move_left": "L", "move_right": "R" }
const FLIP := { "U": "D", "D": "U", "L": "R", "R": "L" }

@onready var arrows: Control = $Panel/VBoxContainer/Arrows

var mirror := false
var hidden := false
var queue: Array[String] = []
var seq := ""
var index := 0
var running := false


func _ready() -> void:
	add_to_group("puzzle_ui")
	hide()

func run(data: PuzzleData, prebuilt: Array[String] = []) -> bool:
	if not prebuilt.is_empty():
		queue = prebuilt.duplicate()
	else:
		queue = data.build()
	mirror = data.modifier == PuzzleData.Mod.MIRROR
	hidden = data.modifier == PuzzleData.Mod.HIDDEN
	_next_sequence()
	running = true
	show()
	var ok: bool = await finished
	running = false
	hide()
	return ok

func _next_sequence() -> void:
	seq = queue.pop_front()
	index = 0
	_redraw()

func _redraw() -> void:
	arrows.seq = seq
	arrows.index = index
	arrows.mirror = mirror
	arrows.hidden_type = hidden
	arrows.custom_minimum_size.x = 28 * seq.length() + 8

func _unhandled_input(event: InputEvent) -> void:
	if not running:
		return
	if event.is_action_pressed("interact"):
		finished.emit(false)
		get_viewport().set_input_as_handled()
		return
	for action in ACTION:
		if event.is_action_pressed(action):
			_press(ACTION[action])
			get_viewport().set_input_as_handled()
			return

func _press(letter: String) -> void:
	if seq == "":
		return
	if mirror:
		letter = FLIP[letter]
	if letter == seq[index]:
		index += 1
		_redraw()
		if index == seq.length():
			solved_one.emit()
			if queue.is_empty():
				finished.emit(true)
			else:
				_next_sequence()
	else:
		index = 0
		mistake.emit()
		arrows._flash = 1.0
		_redraw()

func show_clue(text: String) -> void:
	running = true
	seq = ""
	arrows.clue = text
	arrows.custom_minimum_size.x = 28 * text.length() + 8
	show()
	await finished
	arrows.clue = ""
	running = false
	hide()
