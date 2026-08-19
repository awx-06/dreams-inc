extends CharacterBody2D
class_name Player

const SPEED = 150

@onready var tiles = $".."
@onready var dream: Dream = $".."

signal hearts_changed(h: int)
signal died

const P_COL := Color(0.788, 0.329, 0.898, 1.0) * 2.0   # lavender, glowing
var _t := 0.0
var hearts := 3
var current_tile : DreamTile
var dir
var came_from: DreamTile


func _ready() -> void:
	add_to_group("player")

var moving := false

func _process(_delta: float) -> void:
	_t += _delta
	queue_redraw()
	if moving or current_tile.puzzle_running:
		return
	if Input.is_action_just_pressed("move_up"):
		dir = Vector2i.UP
	elif Input.is_action_just_pressed("move_down"):
		dir = Vector2i.DOWN
	elif Input.is_action_just_pressed("move_left"):
		dir = Vector2i.LEFT
	elif Input.is_action_just_pressed("move_right"):
		dir = Vector2i.RIGHT
	elif Input.is_action_just_pressed("interact") && current_tile.end:
		if current_tile.end and dream.goals_done >= dream.goals_needed:
			dream.win()
			return
		else:
			get_child(2).add_trauma(0.5)
			return
	elif Input.is_action_just_pressed("freeze"):
		if Game.use_item("freeze"):
			for e in dream.enemies:
				e.freeze(2.5)
			$Camera2D.add_trauma(0.3)
		return
	else:
		return
	move_player(dir)

func move_player(d: Vector2i) -> void:
	var target: DreamTile = tiles.neighbor_at(current_tile, d)
	if target == null:
		return
	if not tiles.edge_open(current_tile, target):
		bump(target)
		return
	moving = true
	$Move.play()
	var tw := create_tween()
	tw.tween_property(self, "global_position", target.global_position, 0.18)
	await tw.finished
	current_tile.player_on = false
	came_from = current_tile      # set BEFORE reassigning current_tile
	current_tile = target
	for e in dream.enemies:
		if e.current_tile == current_tile:
			e._catch()
			break
	current_tile.player_on = true
	moving = false

func bump(target: DreamTile) -> void:
	moving = true
	var toward := global_position.lerp(target.global_position, 0.25)
	var tw := create_tween()
	tw.tween_property(self, "global_position", toward, 0.07)
	tw.tween_property(self, "global_position", global_position, 0.07)
	await tw.finished
	moving = false


#func hurt(dmg: int = 1) -> void:
	#print(hearts)
	#if hearts <= 0:
		#return
	#hearts -= dmg
	#get_child(2).add_trauma(0.8)
	#hearts_changed.emit(hearts)
	#var tw := create_tween().set_loops(4)
	#tw.tween_property(self, "modulate:a", 0.25, 0.08)
	#tw.tween_property(self, "modulate:a", 1.0, 0.08)
	#if hearts <= 0:
		#died.emit()
		#print("dream failed — hearts gone")

func hurt(dmg: int = 1) -> void:
	if Game.hearts <= 0:
		return
	Game.hearts -= dmg
	get_child(2).add_trauma(0.8)
	var tw := create_tween().set_loops(4)
	tw.tween_property(self, "modulate:a", 0.25, 0.08)
	tw.tween_property(self, "modulate:a", 1.0, 0.08)
	if Game.hearts <= 0:
		died.emit()

func respawn(tile: DreamTile) -> void:
	current_tile.player_on = false
	current_tile = tile
	came_from = tile
	current_tile.player_on = true
	global_position = tile.global_position
	moving = false

func _draw() -> void:
	var s := 7.0 + sin(_t * 4.0) * 0.6
	var pts := PackedVector2Array([Vector2(0, -s), Vector2(s, 0), Vector2(0, s), Vector2(-s, 0)])
	draw_polyline(pts + PackedVector2Array([pts[0]]), P_COL, 2.0, true)
	draw_circle(Vector2.ZERO, 2.0, P_COL)
