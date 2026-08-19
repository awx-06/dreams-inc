extends Control

const SAMPLES := 48
var t := 0.0

func _ready() -> void:
	custom_minimum_size = Vector2(140, 44)

func _process(delta: float) -> void:
	t += delta
	queue_redraw()

func _draw() -> void:
	var dream = get_tree().get_first_node_in_group("dream")
	if dream == null:
		return
	var d: Vector2i = dream.radar_delta()
	if d.x < 0:
		return
	var mid := size.y * 0.5
	draw_line(Vector2(0, mid), Vector2(size.x, mid), Color(1, 1, 1, 0.15), 1.0)
	var f := 1.0 + d.x * 0.35
	var a := maxf(0.15, 1.0 - d.y * 0.2)
	var ref := PackedVector2Array()
	var live := PackedVector2Array()
	for i in SAMPLES:
		var x := i / float(SAMPLES - 1)
		var px := x * size.x
		ref.append(Vector2(px, mid - sin(x * TAU * 2.0 + t * 2.0) * mid * 0.8))
		live.append(Vector2(px, mid - sin(x * TAU * 2.0 * f + t * 2.0) * mid * 0.8 * a))
	draw_polyline(ref, Color(1, 1, 1, 0.3) * 3, 1.0)
	var closeness := 1.0 / (1.0 + d.x + d.y)
	draw_polyline(live, Color(0.9, 0.35, 0.35).lerp(Color(0.35, 0.95, 0.55) * 3, closeness), 2.0)
