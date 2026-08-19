extends Control

const DIRS := { "U": Vector2(0, -1), "D": Vector2(0, 1), "L": Vector2(-1, 0), "R": Vector2(1, 0) }
const DONE := Color(0.5, 1.0, 0.65) * 1.8
const NEXT := Color(0.9, 0.85, 1.0) * 1.9
const REST := Color(0.75, 0.65, 0.95, 0.35)
const MIRR := Color(1.0, 0.45, 0.55, 0.6)
const RED := Color(1.0, 0.3, 0.35) * 1.5

const FONT_TYPE := preload("res://assets/fonts/m6x11plus.ttf")
const CLUE_COL := Color(0.75, 0.6, 0.95) * 1.6

var seq := ""
var index := 0
var mirror := false
var hidden_type := false
var _t := 0.0
var _flash := 0.0
var clue := ""

func _process(delta: float) -> void:
	_t += delta
	_flash = maxf(_flash - delta * 4.0, 0.0)
	queue_redraw()

func _draw() -> void:
	if clue != "":
		_draw_clue()
		return
	for i in seq.length():
		var c := Vector2(14 + i * 28, 16)
		draw_set_transform(c)
		var col: Color
		var s := 8.0
		if i < index:
			col = DONE
		elif i == index:
			col = NEXT
			s += sin(_t * 6.0) * 1.2
		else:
			col = MIRR if mirror else REST
		col = col.lerp(RED, _flash)
		if hidden_type and i >= index:
			draw_circle(Vector2.ZERO, 3.0, col)
		else:
			var d: Vector2 = DIRS[seq[i]]
			var p := d.orthogonal()
			var tip := d * s
			var a := -d * s * 0.6 + p * s * 0.7
			var b := -d * s * 0.6 - p * s * 0.7
			draw_polyline(PackedVector2Array([a, tip, b]), col, 2.5, true)
	draw_set_transform(Vector2.ZERO)

func _draw_clue() -> void:
	for i in clue.length():
		var ch := clue[i]
		if not DIRS.has(ch):
			continue
		var c := Vector2(14 + i * 28, 16)
		draw_set_transform(c)
		var d: Vector2 = DIRS[ch]
		var p := d.orthogonal()
		var s := 8.0
		var tip := d * s
		var a := -d * s * 0.6 + p * s * 0.7
		var b := -d * s * 0.6 - p * s * 0.7
		draw_polyline(PackedVector2Array([a, tip, b]), CLUE_COL, 2.5, true)
	draw_set_transform(Vector2.ZERO)
