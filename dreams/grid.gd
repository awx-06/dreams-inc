extends Node2D

@export var cell := 64.0
@export var extent := 30      # cells in each direction from origin
@export var dot_col := Color(1, 1, 1, 0.08)

func _draw() -> void:
	for x in range(-extent, extent):
		for y in range(-extent, extent):
			draw_circle(Vector2(x, y) * cell, 1.5, dot_col)
