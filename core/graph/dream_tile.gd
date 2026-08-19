class_name DreamTile
extends Node2D


@export var connections: Array[DreamTile] = []
@export var start := false
@export var puzzle = false
@export var end = false
@export var enemy = false
@export var puzzleDate: PuzzleData
@export var linked: Array[DreamTile] = []
@export var self_locking := true
@export var counts_toward_goal := false
@export var clue_text := "" 
@export var locked_dirs: Array[String] = []
@export var start_sealed := false

const GLYPH := { "U": "↑", "D": "↓", "L": "←", "R": "→" }
const GLOW := 1.5

var base_color := Color.WHITE
var sealed := {}
var rolled: Array[String] = []
var solved := false
var color := Color.WHITE
var player_on = false
var puzzle_running = false
var _t := 0.0


func _ready() -> void:
	if start_sealed:
		if locked_dirs.is_empty():
			for d in ["U", "D", "L", "R"]:
				sealed[d] = true
		else:
			for d in locked_dirs:
				sealed[d] = true
	refresh_visual()

func _process(delta: float) -> void:
	_t += delta
	var pulse := 1.0 + sin(_t * 2.0 + position.x * 0.05) * 0.03
	scale = Vector2(pulse, pulse)
	queue_redraw()


func is_fully_sealed() -> bool:
	return sealed.size() == 4

func blocks(dir: String) -> bool:
	return sealed.get(dir, false)

func toggle_seals() -> void:
	var dirs: Array = locked_dirs if not locked_dirs.is_empty() else ["U", "D", "L", "R"]
	for d in dirs:
		if sealed.get(d, false):
			sealed.erase(d)
		else:
			sealed[d] = true
	refresh_visual()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_on:
		if clue_text != "":
			var ui = get_child(0)
			if not ui.running:
				ui.show_clue(clue_text)
		elif puzzle:
			var ui = get_child(0)
			if not ui.running:
				_go(ui)

func _go(ui) -> void:
	puzzle_running = true
	var ok: bool = await open_puzzle(ui)
	puzzle_running = false
	print("result: ", ok, "  solved: ", solved)

#func _draw() -> void:
	#draw_circle(Vector2.ZERO, 12.0, color)

func _draw() -> void:
	var glyph_col := color
	# soft inner disc — the "light source" behind the ring
	draw_circle(Vector2.ZERO, 10.0, Color(color.r, color.g, color.b, 0.12))
	# the ring itself
	draw_arc(Vector2.ZERO, 11.0, 0.0, TAU, 32, color, 2.0, true)
	# state glyph inside the ring
	if puzzle and self_locking:
		# door: small diamond
		draw_polygon([Vector2(0, -5), Vector2(5, 0), Vector2(0, 5), Vector2(-5, 0)],
			[Color(color.r, color.g, color.b, 0.9)])
	elif puzzle:
		# switch: horizontal bar
		draw_line(Vector2(-5, 0), Vector2(5, 0), glyph_col, 2.0)
	elif clue_text != "":
		# archive: a dot in a ring — an eye
		draw_arc(Vector2.ZERO, 5.0, 0.0, TAU, 16, glyph_col, 1.0, true)
		draw_circle(Vector2.ZERO, 1.5, glyph_col)
	elif sealed.size() > 0:
		# sealed partner: an X
		draw_line(Vector2(-4, -4), Vector2(4, 4), glyph_col, 1.5)
		draw_line(Vector2(-4, 4), Vector2(4, -4), glyph_col, 1.5)

func open_puzzle(ui) -> bool:
	if puzzleDate == null:
		push_warning(name + " has puzzle ticked but no PuzzleData")
		return false
	if rolled.is_empty():
		rolled = puzzleDate.build()
	var ok = await ui.run(puzzleDate, rolled)
	if ok:
		if not solved and counts_toward_goal:
			solved = true
			get_tree().get_first_node_in_group("dream").goal_solved()
		else:
			solved = true
		if self_locking:
			toggle_seals()
		for t in linked:
			if t == null:
				push_warning(name + " has an empty linked slot")
				continue
			t.toggle_seals()
			t.refresh_visual()
		refresh_visual()
	return ok

func refresh_visual() -> void:
	print(name, "  sealed=", sealed.size(), "  puzzle=", puzzle)
	var c: Color
	if puzzle:
		# host: green when open (solved through), lock-color when sealed
		if sealed.size() > 0:
			c = Color(0.95, 0.75, 0.3)      # amber — host lock
		elif solved:
			c = Color(0.35, 0.95, 0.5)  
		else:
			c = Color(0.2, 0.60, 0.90)
	elif linked_partner_style():
		# partner: red when sealed, white when open
		c = Color(0.85, 0.2, 0.25) if sealed.size() > 0 else Color.WHITE
	elif clue_text != "":
		c = Color(0.6, 0.4, 0.85)
	else:
		c = Color.WHITE
	base_color = c
	color = base_color * (GLOW if (puzzle or clue_text != "" or sealed.size() > 0) else 1.0)
	queue_redraw()

func linked_partner_style() -> bool:
	return not locked_dirs.is_empty() or sealed.size() > 0

#func can_enter() -> bool:
	#return not locked or puzzle
