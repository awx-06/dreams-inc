extends Control

@export var glyph := "◈"
@export var suffix := ""
@export var col := Color(0.118, 0.678, 0.348, 1.0) * 1.6
var value := 0:
	set(v):
		if v != value:
			_flash = 1.0
		value = v
var _flash := 0.0
var _t := 0.0

func _process(delta: float) -> void:
	_t += delta
	_flash = maxf(_flash - delta * 3.0, 0.0)
	queue_redraw()

func _draw() -> void:
	var f := ThemeDB.fallback_font
	var c := col.lerp(Color.WHITE * 2.0, _flash)
	var scl := 1.0 + _flash * 0.25
	draw_set_transform(Vector2(0, size.y * 0.5), 0.0, Vector2(scl, scl))
	draw_string(f, Vector2(0, 5), glyph + " " + str(value) + suffix, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, c)
	draw_set_transform(Vector2.ZERO)
