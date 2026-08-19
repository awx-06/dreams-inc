extends CanvasLayer

@onready var time_bar: Control = $MarginContainer/VBoxContainer/Time
@onready var hearts_draw: Control = $MarginContainer/VBoxContainer/Hearts
@onready var goals_draw: Control = $MarginContainer/VBoxContainer/Goals

var total_time := 1.0

func setup(total: float, hearts: int) -> void:
	total_time = maxf(total, 0.001)
	time_bar.ratio = 1.0
	hearts_draw.max_hearts = Game.MAX_HEARTS
	set_hearts(hearts)

func set_time(t: float) -> void:
	time_bar.ratio = clampf(t / total_time, 0.0, 1.0)

func set_hearts(h: int) -> void:
	hearts_draw.hearts = maxi(h, 0)

func set_goals(done: int, needed: int) -> void:
	if needed <= 0:
		goals_draw.visible = false
		return
	goals_draw.visible = true
	goals_draw.value = done
	goals_draw.suffix = " / %d" % needed
