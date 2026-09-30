extends Node2D

const HojaSusto = preload("res://cliente/secuencias/susto/hoja_susto.gd")

func _draw() -> void:
	# Dibujamos solo la cama (madera y almohada) ya que los personajes ahora son sprites
	var madera := Color("684337")
	draw_rect(Rect2(-14, -23, 28, 26), madera)
	draw_rect(Rect2(-12, -21, 24, 6), Color("d1c5a6"))
	draw_rect(Rect2(-13, 2, 3, 3), madera)
	draw_rect(Rect2(10, 2, 3, 3), madera)

func _ready() -> void:
	# ABUELO (Acostado / Caído)
	var spr_abuelo = AnimatedSprite2D.new()
	var frames = HojaSusto.crear_frames()
	if frames:
		spr_abuelo.sprite_frames = frames
		spr_abuelo.animation = "caido"
		spr_abuelo.frame = 1 # Usa el último frame de caída para simular que está en cama
		spr_abuelo.scale = Vector2(HojaSusto.ESCALA, HojaSusto.ESCALA)
		spr_abuelo.position = Vector2(0, -10)
		spr_abuelo.rotation = deg_to_rad(90) # Rotar 90 positivo para que la cabeza quede en la almohada
		$Abuelo.add_child(spr_abuelo)
		
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
