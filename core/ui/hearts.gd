extends Control

const FULL := Color(1.0, 0.35, 0.55) * 1.8
const EMPTY := Color(1.0, 0.35, 0.55, 0.18)
var hearts := 3
var max_hearts := 5
var _t := 0.0

func _process(delta: float) -> void:
	_t += delta
	queue_redraw()

func _draw() -> void:
	for i in max_hearts:
		var c := Vector2(10 + i * 18, 10)
		draw_set_transform(c)
		var s := 5.0
		if i < hearts:
			s += sin(_t * 3.0 + i * 0.7) * 0.5
		var col := FULL if i < hearts else EMPTY
		var pts := PackedVector2Array([Vector2(0, -s), Vector2(s, 0), Vector2(0, s), Vector2(-s, 0)])
		draw_polyline(pts + PackedVector2Array([pts[0]]), col, 1.5, true)
		if i < hearts:
			draw_circle(Vector2.ZERO, 1.5, col)
	draw_set_transform(Vector2.ZERO)
