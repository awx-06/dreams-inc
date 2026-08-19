extends Camera2D

const DECAY = 2
const MAX_OFFSET = 6
var trauma = 0.0

func add_trauma(amount):
	trauma = minf(trauma + amount, 1)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if trauma > 0:
		trauma = maxf(0, trauma - DECAY * delta)
		offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * MAX_OFFSET * trauma * trauma
	else: 
		offset = Vector2.ZERO
