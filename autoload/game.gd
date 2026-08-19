extends Node

signal money_changed(amount: int)
signal hearts_changed(h: int)

const POOL_SIZE := 3
const MAX_HEARTS := 5

const CLIENTS := [
	{ "name": "Layla", "problem": "I keep having this dream where I'm trying to get home, but the street just never seems to end. Could you help me please?", "level": 1, "reward": 10, "scene": "res://dreams/dream_1.tscn" },
	{ "name": "Sami", "problem": "There's this thing that follows me whenever I dream. It's not exactly scary, but it's really annoying.", "level": 2, "reward": 20, "scene": "res://dreams/dream_2.tscn" },
	{ "name": "Nour", "problem": "I found this really beautiful garden in one of my dreams, but there's a gate that keeps changing whenever I touch it.", "level": 3, "reward": 30, "scene": "res://dreams/dream_3.tscn" },
	{ "name": "Karim", "problem": "I keep dreaming about being in a museum looking for keys, the weird part is that the museum is never empty.", "level": 4, "reward": 100, "scene": "res://dreams/dream_4.tscn" },
	{ "name": "Dana", "problem": "I don't know how else to explain this. Something is always right behind me. I can hear it getting closer while I'm trying to think.", "level": 5, "reward": 45, "scene": "res://dreams/dream_5.tscn" },
	{ "name": "leah", "problem": "I had this dream about my childhood home, except none of the rooms were where they were supposed to be. I think there's something hidden.", "level": 5, "reward": 60, "scene": "res://dreams/dream_6.tscn" }
]

const SHOP := [
	{ "id": "heart", "name": "Heart", "desc": "+1 waking heart", "cost": 60, "repeat": true },
	{ "id": "time", "name": "Lucid Watch", "desc": "+15s in every dream", "cost": 90, "repeat": false },
	#{ "id": "steady", "name": "Steady Hands", "desc": "Mistakes forgiven once per puzzle", "cost": 120, "repeat": false },
	{ "id": "freeze", "name": "Cleanse", "desc": "Freeze all nightmares, 1s", "cost": 20, "repeat": true },
	#{ "id": "bullet", "name": "Waking Shot", "desc": "Erase one nightmare", "cost": 150, "repeat": true },
]

signal items_changed

var items := { "freeze": 0, "bullet": 0 }
var owned: Array[String] = []
var pool: Array[int] = []
var next_index := 0
var current_client := -1
var last_result: Dictionary = {}
var repaired_count = 0


var money := 0:
	set(v):
		money = v
		money_changed.emit(money)

var hearts := 3:
	set(v):
		hearts = clampi(v, 0, MAX_HEARTS)
		hearts_changed.emit(hearts)


func start_run() -> void:
	items = { "freeze": 0, "bullet": 0 }
	owned.clear()
	money = 20
	hearts = 3
	repaired_count = 0
	current_client = -1
	pool.clear()
	next_index = 0
	while pool.size() < POOL_SIZE and next_index < CLIENTS.size():
		pool.append(next_index)
		next_index += 1

func client_repaired(i: int) -> void:
	repaired_count += 1
	money += CLIENTS[i].reward
	pool.erase(i)
	if next_index < CLIENTS.size():
		pool.append(next_index)
		next_index += 1

func can_buy(item: Dictionary) -> bool:
	if money < item.cost:
		return false
	if item.id == "heart" and hearts >= MAX_HEARTS:
		return false
	if not item.repeat and owned.has(item.id):
		return false
	return true

func buy(item: Dictionary) -> void:
	if not can_buy(item):
		return
	money -= item.cost
	match item.id:
		"heart":
			hearts += 1
		"bullet", "freeze":
			add_item(item.id)
		_:
			owned.append(item.id)


func add_item(id: String) -> void:
	items[id] += 1
	items_changed.emit()

func use_item(id: String) -> bool:
	if items[id] <= 0:
		return false
	items[id] -= 1
	items_changed.emit()
	return true
