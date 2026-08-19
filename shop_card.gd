class_name ShopCard
extends PanelContainer

@onready var name_label: Label = $MarginContainer/VBoxContainer/Name
@onready var desc_label: Label = $MarginContainer/VBoxContainer/Desc
@onready var buy_button: Button = $MarginContainer/VBoxContainer/Buy

var item: Dictionary

func setup(i: Dictionary) -> void:
	item = i
	name_label.text = i.name
	desc_label.text = i.desc
	buy_button.pressed.connect(_buy)
	refresh()

func refresh() -> void:
	if not item.repeat and Game.owned.has(item.id):
		buy_button.text = "OWNED"
	else:
		buy_button.text = "✦%d" % item.cost
	buy_button.disabled = not Game.can_buy(item)

func _buy() -> void:
	Clicks.play(0.3)
	Game.buy(item)
	
