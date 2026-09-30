extends TextureRect

func _get_drag_data(_at_position: Vector2):
	var preview = TextureRect.new()
	preview.texture = texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.custom_minimum_size = size
	preview.modulate.a = 0.5
	
	var control = Control.new()
	control.add_child(preview)
	preview.position = -0.5 * size
	
	set_drag_preview(control)
	return self
