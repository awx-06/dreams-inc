class_name Enemy
extends Node2D

@export var step_interval := 2.0
@onready var dream: Dream = $".."

const E_COL := Color(0.689, 0.0, 0.115, 1.0) * 2.2
var _t := 0.0
var spawn_tile
var current_tile: DreamTile
var player: Player
var frozen := false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	var t := Timer.new()
	t.wait_time = step_interval
	t.autostart = true
	t.timeout.connect(_heartbeat)
	add_child(t)

func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func freeze(duration: float) -> void:
	if frozen:
		return
	frozen = true
	var t: Timer = get_child(0)
	t.paused = true
	modulate = Color(0.5, 0.75, 1.0)
	await get_tree().create_timer(duration).timeout
	t.paused = false
	modulate = Color.WHITE
	frozen = false

func _heartbeat() -> void:
	var next := dream.next_step_toward(current_tile, player.current_tile)
	if next == null:
		return
	for e in dream.enemies:
		if e != self and e.current_tile == next:
			return
	var tw := create_tween()
	tw.tween_property(self, "global_position", next.global_position, 0.3)
	await tw.finished
	current_tile = next
	if current_tile == player.current_tile:
		_catch()

func _draw() -> void:
	var pts := PackedVector2Array()
	var n := 9
	for i in n:
		var a := TAU * i / n + sin(_t * 7.0 + i) * 0.15
		var r := 13.0 + (4.0 if i % 2 == 0 else -3.0) + sin(_t * 11.0 + i * 2.0) * 1.5
		pts.append(Vector2(cos(a), sin(a)) * r)
	pts.append(pts[0])
	draw_polyline(pts, E_COL, 2.0, false)
	draw_circle(Vector2.ZERO, 3.0, E_COL)

func _catch() -> void:
	print("caught")
	dream.on_player_caught()

func respawn() -> void:
	current_tile = spawn_tile
	global_position = spawn_tile.global_position
	modulate.a = 0.4
	await get_tree().create_timer(1.5).timeout
	modulate.a = 1.0
