extends Control

const COL := Color(0.78, 0.66, 0.94) * 1.6
var ratio := 1.0
var _t := 0.0

func _process(delta: float) -> void:
	_t += delta
	queue_redraw()

func _draw() -> void:
	var w := size.x
	draw_rect(Rect2(0, 2, w, 4), Color(COL.r, COL.g, COL.b, 0.12))
	var fill := w * ratio
	var col := COL if ratio > 0.25 else COL.lerp(Color(1.0, 0.3, 0.3) * 1.8, sin(_t * 8.0) * 0.5 + 0.5)
	draw_rect(Rect2(0, 2, fill, 4), col)
	draw_line(Vector2(fill, 0), Vector2(fill, 8), col, 2.0)     # bright leading edge
