extends Node2D

@onready var ui: CanvasLayer = $PuzzzleUI
@onready var tile: DreamTile = $DreamTile

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not ui.running:
		_go()

func _go() -> void:
	var ok: bool = await tile.open_puzzle(ui)
	print("result: ", ok, "  solved: ", tile.solved)
