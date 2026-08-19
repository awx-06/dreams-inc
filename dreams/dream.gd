class_name Dream
extends Node2D

const ENEMY_SCENE = preload("res://core/hazard/enemy.tscn")  

@onready var player: Player = $Player
@onready var enemy: Enemy = $Enemy
@onready var hud = $HUD

@export var has_enemy = false
@export var dream_time = 100

const CELL := 64.0

const DIR_NAME := {
	Vector2i(0, -1): "U", Vector2i(0, 1): "D",
	Vector2i(-1, 0): "L", Vector2i(1, 0): "R",
}
const OPPOSITE := { "U": "D", "D": "U", "L": "R", "R": "L" }

var enemies: Array = []
var goals_needed := 0
var goals_done := 0
var end_tile: DreamTile
var time_left: float
var adjacency: Dictionary = {}
var edges: Dictionary = {}
var grid: Dictionary = {}

func _ready() -> void:
	add_to_group("dream")
	_build_graph()
	_build_edges()
	var start := get_start_tile()
	player.position = start.position
	player.current_tile = start
	var i := 0
	for tile in adjacency:
		if tile.enemy:
			var e := ENEMY_SCENE.instantiate()
			e.step_interval = 2.0 + i * 0.25
			add_child(e)
			e.global_position = tile.global_position
			e.current_tile = tile
			e.spawn_tile = tile
			enemies.append(e)
			i += 1
	time_left = dream_time
	hud.setup(dream_time, player.hearts)
	Game.hearts_changed.connect(hud.set_hearts)
	hud.set_goals(goals_done, goals_needed)

func _process(_delta: float) -> void:
	time_left -= _delta
	hud.set_time(time_left)
	if time_left <= 0.0:
		Game.hearts -= 1
		lose("time")


func _build_graph() -> void:
	for tile in $Tiles.get_children():
		if tile.end:
			end_tile = tile
		if tile.counts_toward_goal:
			goals_needed += 1
		if tile is DreamTile:
			grid[_cell_of(tile)] = tile
	for cell in grid:
		var tile: DreamTile = grid[cell]
		adjacency[tile] = []
		for offset in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			if grid.has(cell + offset):
				adjacency[tile].append(grid[cell + offset])

func _cell_of(tile: DreamTile) -> Vector2i:
	return Vector2i((tile.position / CELL).round())

func neighbor_at(tile: DreamTile, dir: Vector2i) -> DreamTile:
	return grid.get(_cell_of(tile) + dir)

func next_step_toward(from: DreamTile, to: DreamTile) -> DreamTile:
	if from == to:
		return null
	var visited := { from: true }
	var frontier: Array = []                    # entries: [tile, first_step]
	var best_step: DreamTile = null
	var best_dist := from.global_position.distance_to(to.global_position)
	for n in adjacency[from]:
		if edge_open(from, n):
			frontier.append([n, n])
			visited[n] = true
	while not frontier.is_empty():
		var entry: Array = frontier.pop_front()
		var tile: DreamTile = entry[0]
		var first: DreamTile = entry[1]
		if tile == to:
			return first
		var d := tile.global_position.distance_to(to.global_position)
		if d < best_dist:
			best_dist = d
			best_step = first
		for n in adjacency[tile]:
			if not visited.has(n) and edge_open(tile, n):
				visited[n] = true
				frontier.append([n, first])
	return best_step

func edge_open(a: DreamTile, b: DreamTile) -> bool:
	var delta := _cell_of(b) - _cell_of(a)
	if not DIR_NAME.has(delta):
		return false
	var d: String = DIR_NAME[delta]
	return not a.blocks(d) and not b.blocks(OPPOSITE[d])

func get_start_tile() -> DreamTile:
	for tile in adjacency:
		if tile.start:
			return tile
	push_warning("No tile has is_start checked — using first tile")
	return adjacency.keys()[0]

func get_enemy_tile() -> DreamTile:
	for tile in adjacency:
		if tile.enemy:
			return tile
	push_warning("No tile has is_start checked — using first tile")
	return adjacency.keys()[0]

func _build_edges() -> void:
	for tile in adjacency:
		for other in adjacency[tile]:
			var key := _edge_key(tile, other)
			if edges.has(key):
				continue
			var line := Line2D.new()
			line.width = 2.0
			line.default_color = Color(1, 1, 1, 0.25)
			line.z_index = -1
			line.add_point(tile.position)
			line.add_point(other.position)
			$Tiles.add_child(line)
			edges[key] = line

func _edge_key(a: DreamTile, b: DreamTile) -> String:
	var i := a.get_instance_id()
	var j := b.get_instance_id()
	return "%d_%d" % [mini(i, j), maxi(i, j)]

func set_edge_color(a: DreamTile, b: DreamTile, color: Color) -> void:
	var key := _edge_key(a, b)
	if edges.has(key):
		edges[key].default_color = color


func on_player_caught() -> void:
	player.hurt(1)
	if Game.hearts <= 0:
		lose("hearts")
		return
	player.respawn(get_start_tile())
	for e in enemies:
		e.respawn()

func win() -> void:
	set_process(false)
	Game.last_result = { "won": true, "reward": Game.CLIENTS[Game.current_client].reward }
	Game.client_repaired(Game.current_client)
	Flow.goto("res://core/ui/result.tscn")

func lose(reason: String) -> void:
	set_process(false)
	Game.last_result = { "won": false, "reason": reason }
	Flow.goto("res://core/ui/result.tscn")

func goal_solved() -> void:
	goals_done += 1
	hud.set_goals(goals_done, goals_needed)

func radar_delta() -> Vector2i:
	if end_tile == null or player.current_tile == null:
		return Vector2i(-1, -1)
	var d := _cell_of(end_tile) - _cell_of(player.current_tile)
	return Vector2i(absi(d.x), absi(d.y))
