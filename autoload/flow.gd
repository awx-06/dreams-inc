extends CanvasLayer

var shot: TextureRect
var mat: ShaderMaterial
var busy := false

func _ready() -> void:
	layer = 100
	shot = TextureRect.new()
	shot.set_anchors_preset(Control.PRESET_FULL_RECT)
	shot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shot.stretch_mode = TextureRect.STRETCH_SCALE
	shot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mat = ShaderMaterial.new()
	mat.shader = preload("res://hub/flow.gdshader")
	shot.material = mat
	shot.visible = false
	add_child(shot)

func goto(path: String) -> void:
	if busy:
		return
	busy = true
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	shot.texture = ImageTexture.create_from_image(img)
	mat.set_shader_parameter("progress", 0.0)
	shot.visible = true
	get_tree().change_scene_to_file(path)
	var tw := create_tween()
	tw.tween_property(mat, "shader_parameter/progress", 1.0, 0.7)
	await tw.finished
	shot.visible = false
	busy = false
