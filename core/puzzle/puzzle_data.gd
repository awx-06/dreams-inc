class_name PuzzleData
extends Resource

enum Mod { NONE, MEMORY, MIRROR, HIDDEN }

@export var fixed: Array[String] = []
@export var count: int = 1
@export var length: int = 4
@export var modifier: Mod = Mod.NONE

func build() -> Array[String]:
	if not fixed.is_empty():
		return fixed.duplicate()
	var out: Array[String] = []
	for i in count:
		var s := ""
		for j in length:
			s += "UDLR"[randi() % 4]
		out.append(s)
	return out
