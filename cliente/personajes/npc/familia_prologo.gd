extends Node2D

const HojaSusto = preload("res://cliente/secuencias/susto/hoja_susto.gd")
const TexturaCama = preload("res://cliente/tiles_raw/interiores/tileset_bed.png")

func _ready() -> void:
	# ABUELO (Acostado / Caído)
	var spr_abuelo = AnimatedSprite2D.new()
	var frames = HojaSusto.crear_frames()
	if frames:
		spr_abuelo.sprite_frames = frames
		spr_abuelo.animation = "caido"
		spr_abuelo.frame = 1 # Usa el último frame de caída para simular que está en cama
		spr_abuelo.scale = Vector2(HojaSusto.ESCALA, HojaSusto.ESCALA)
		spr_abuelo.position = Vector2(9, -10)
		# La última fila ya está acostada; se gira para seguir la cama vertical.
		spr_abuelo.rotation = PI / 2.0
		$Abuelo.add_child(spr_abuelo)
		# Repetimos la zona de cobija por encima de las piernas para que se vea
		# arropado y no de pie sobre el colchón.
		var cobija := Sprite2D.new()
		cobija.texture = TexturaCama
		cobija.region_enabled = true
		cobija.region_rect = Rect2(0, 25, 32, 16)
		cobija.position = Vector2(0, 0)
		$Abuelo.add_child(cobija)
		
	# ABUELA (De pie)
	var spr_abuela = Sprite2D.new()
	var tex_abuela = load("res://cliente/sprites/npc/abuela/abuela.png")
	if tex_abuela:
		spr_abuela.texture = tex_abuela
		spr_abuela.region_enabled = true
		# Recorte perfecto calculado para evitar atrapar sombreros flotantes de otros frames
		spr_abuela.region_rect = Rect2(117, 28, 158, 279)
		spr_abuela.scale = Vector2(HojaSusto.ESCALA, HojaSusto.ESCALA)
		spr_abuela.position = Vector2(0, -15)
		$Abuela.add_child(spr_abuela)
