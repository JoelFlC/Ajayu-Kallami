extends Control

func _ready() -> void:
	# Fondo oscuro
	var fondo = ColorRect.new()
	fondo.color = Color("07131f")
	fondo.set_anchors_preset(PRESET_FULL_RECT)
	add_child(fondo)
	
	# Textura HUD para recortes
	var tex_hud = preload("res://cliente/sprites/ui/hud_andino.png")
	
	# Marco / Mesa en el centro (Drop Zone)
	var mesa = TextureRect.new()
	var atlas_mesa = AtlasTexture.new()
	atlas_mesa.atlas = tex_hud
	atlas_mesa.region = Rect2(1288, 15, 370, 198)
	mesa.texture = atlas_mesa
	mesa.custom_minimum_size = Vector2(240, 160)
	mesa.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	mesa.position = Vector2(120, 50)
	mesa.set_script(preload("res://cliente/niveles/pruebas/drop_zone.gd"))
	add_child(mesa)
	
	# ColorRect interior para tapar el texto horneado del hud
	var tapar = ColorRect.new()
	tapar.color = Color("07131f")
	tapar.set_anchors_preset(PRESET_FULL_RECT)
	tapar.offset_left = 30
	tapar.offset_top = 20
	tapar.offset_right = -30
	tapar.offset_bottom = -20
	mesa.add_child(tapar)
	
	# Titulo
	var titulo = Label.new()
	titulo.text = "Prepara la Ofrenda"
	titulo.add_theme_color_override("font_color", Color("efb44f"))
	titulo.set_anchors_preset(PRESET_TOP_WIDE)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.offset_top = 10
	add_child(titulo)

	# Elementos fijos que ya están en la mesa (Prenda y Tierra)
	var prenda = TextureRect.new()
	var atlas_prenda = AtlasTexture.new()
	atlas_prenda.atlas = tex_hud
	atlas_prenda.region = Rect2(505, 778, 76, 64)
	prenda.texture = atlas_prenda
	prenda.position = Vector2(80, 50)
	mesa.add_child(prenda)
	
	var tierra = TextureRect.new()
	var atlas_tierra = AtlasTexture.new()
	atlas_tierra.atlas = tex_hud
	atlas_tierra.region = Rect2(621, 782, 78, 59)
	tierra.texture = atlas_tierra
	tierra.position = Vector2(100, 70)
	mesa.add_child(tierra)
	
	# Elemento Arrastrable (La miniatura)
	# Usamos un pedacito genérico del hud para la miniatura
	var miniatura = TextureRect.new()
	var atlas_mini = AtlasTexture.new()
	atlas_mini.atlas = tex_hud
	atlas_mini.region = Rect2(505, 778, 40, 40) # Algo pequeño
	miniatura.texture = atlas_mini
	miniatura.position = Vector2(40, 200)
	miniatura.set_script(preload("res://cliente/niveles/pruebas/drag_item.gd"))
	add_child(miniatura)
	
	var label_mini = Label.new()
	label_mini.text = "Miniatura"
	label_mini.add_theme_font_size_override("font_size", 10)
	label_mini.position = Vector2(0, 45)
	miniatura.add_child(label_mini)
