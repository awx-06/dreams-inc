extends Control

const CARD := preload("res://core/ui/client_card.tscn")
const SHOP_CARD := preload("res://core/ui/shop_card.tscn")

@onready var shop_list: VBoxContainer = $Window/MarginContainer/VBoxContainer/HBoxContainer2/Shop
@onready var client_list: VBoxContainer = $Window/MarginContainer/VBoxContainer/HBoxContainer2/ClientList
@onready var hearts_draw: Control = $Window/MarginContainer/VBoxContainer/HBoxContainer/Hearts
@onready var money_label: Control = $Window/MarginContainer/VBoxContainer/HBoxContainer/Money

func _ready() -> void:                      # still debug — title screen takes this later
	Game.money_changed.connect(_on_money)
	Game.hearts_changed.connect(_on_hearts)
	Game.money_changed.connect(_refresh_shop)
	Game.hearts_changed.connect(_refresh_shop)
	_on_money(Game.money)
	_on_hearts(Game.hearts)
	_refresh_clients()
	_build_shop()
	hearts_draw.max_hearts = Game.MAX_HEARTS
	

func _on_money(m: int) -> void:
	money_label.value = m

func _on_hearts(h: int) -> void:
	hearts_draw.hearts = maxi(h, 0)

func _refresh_clients() -> void:
	print("entered refresh clients")
	for c in client_list.get_children():
		c.queue_free()
	for i in Game.pool:
		print(i)
		var card := CARD.instantiate()
		client_list.add_child(card)
		card.setup(i)

func _build_shop() -> void:
	for it in Game.SHOP:
		var card := SHOP_CARD.instantiate()
		shop_list.add_child(card)
		card.setup(it)

func _refresh_shop() -> void:
	for c in shop_list.get_children():
		c.refresh()
