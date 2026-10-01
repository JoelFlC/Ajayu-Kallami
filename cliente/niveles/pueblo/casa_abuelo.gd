extends Node2D

const CAMPAMENTO = preload("res://cliente/tiles_raw/interiores/tileset_camp.png")
const ELEMENTOS = preload("res://cliente/sprites/tiles_raw/TilesetElement.png")

const TAMANO = Vector2(192, 128)


func _ready() -> void:
	if visible:
		$Camera2D.make_current()


func _draw() -> void:
	# El fondo cubre la vista alrededor del cuarto: el pueblo no se ve detrás.
	draw_rect(Rect2(-220, -190, 632, 508), Color("171b21"))
	draw_rect(Rect2(Vector2.ZERO, TAMANO), Color("68483b"))
	# Suelo de tierra apisonada con desgaste irregular, sin patrón repetido.
	draw_rect(Rect2(8, 24, 176, 96), Color("8a6650"))
	for fila in range(1, 7):
		for columna in range(1, 11):
			if (columna + fila * 3) % 7 == 0:
				var piedra := Vector2(columna * 16 + 3, fila * 16 + 8)
				draw_rect(Rect2(piedra, Vector2(4, 2)), Color("a47b5c"))
				draw_rect(Rect2(piedra + Vector2(4, 1), Vector2(2, 1)), Color("765241"))
	# Adobe, zócalo y vigas visibles en la pared posterior.
	draw_rect(Rect2(8, 8, 176, 17), Color("a67858"))
	for columna in range(1, 11):
		var desplazamiento := 7 if columna % 2 == 0 else 0
		draw_rect(Rect2(columna * 16 + desplazamiento, 10, 1, 12), Color("805a45", 0.55))
	draw_rect(Rect2(8, 22, 176, 3), Color("55392f"))
	draw_rect(Rect2(8, 24, 176, 2), Color("c18b5a"))
	draw_rect(Rect2(0, 0, 192, 8), Color("4a3029"))
	draw_rect(Rect2(0, 0, 8, 128), Color("5d3d31"))
	draw_rect(Rect2(184, 0, 8, 128), Color("5d3d31"))
	draw_rect(Rect2(8, 8, 2, 110), Color("bd8b62"))
	draw_rect(Rect2(182, 8, 2, 110), Color("bd8b62"))
	draw_rect(Rect2(0, 120, 192, 8), Color("49322b"))
	for x in [13, 57, 136, 178]:
		draw_rect(Rect2(x, 2, 3, 21), Color("7b4f37"))
		draw_rect(Rect2(x + 2, 2, 1, 21), Color("ce935c"))
	# Ventana nocturna y tejido colgado, propios de una vivienda habitada.
	draw_rect(Rect2(23, 9, 28, 16), Color("4c3028"))
	draw_rect(Rect2(26, 11, 22, 11), Color("1c3040"))
	draw_rect(Rect2(27, 12, 19, 2), Color("42536a"))
	draw_rect(Rect2(36, 11, 2, 11), Color("9d704d"))
	draw_rect(Rect2(26, 17, 22, 2), Color("9d704d"))
	draw_rect(Rect2(22, 22, 30, 2), Color("d0a16c"))
	_dibujar_tejido_pared()
	# Los muebles son Sprite2D independientes en la escena, no recortes
	# mezclados con esta capa de suelo y paredes.
	_dibujar_fogon()
	_dibujar_estante()
	_dibujar_tejido_suelo()
	draw_texture_rect_region(ELEMENTOS, Rect2(18, 74, 32, 24), Rect2(192, 64, 64, 48), Color(0.71, 0.63, 0.51))
	# Umbral marcado para que la salida se lea de inmediato.
	draw_rect(Rect2(75, 116, 42, 4), Color("3d2925"))
	draw_rect(Rect2(77, 117, 38, 2), Color("d59d5b"))
	draw_rect(Rect2(77, 120, 38, 8), Color("95623d"))
	draw_rect(Rect2(88, 114, 16, 2), Color("edc87b"))
	draw_rect(Rect2(123, 106, 49, 13), Color("392b2b"))
	draw_rect(Rect2(124, 107, 47, 11), Color("654233"))
	draw_string(ThemeDB.fallback_font, Vector2(127, 115), "E: salir", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("f4dfb4"))


func _dibujar_fogon() -> void:
	draw_rect(Rect2(116, 33, 26, 17), Color("4c3a32"))
	draw_rect(Rect2(119, 35, 20, 11), Color("a88b6b"))
	draw_rect(Rect2(122, 37, 14, 7), Color("342b2c"))
	draw_texture_rect_region(CAMPAMENTO, Rect2(122, 39, 14, 7), Rect2(0, 0, 32, 16))
	draw_colored_polygon(PackedVector2Array([Vector2(127, 40), Vector2(125, 35), Vector2(129, 28), Vector2(132, 36), Vector2(130, 40)]), Color("e28b46"))
	draw_colored_polygon(PackedVector2Array([Vector2(128, 40), Vector2(128, 35), Vector2(130, 32), Vector2(131, 39)]), Color("f8d17a"))
	draw_rect(Rect2(115, 48, 29, 2), Color("6c5141"))


func _dibujar_estante() -> void:
	draw_rect(Rect2(145, 13, 31, 3), Color("593a2d"))
	draw_rect(Rect2(145, 11, 31, 2), Color("ba8455"))
	for x in [148, 157, 167]:
		draw_rect(Rect2(x + 1, 6, 5, 5), Color("a65d3f"))
		draw_rect(Rect2(x, 8, 7, 3), Color("c97d4e"))
		draw_rect(Rect2(x + 2, 5, 3, 2), Color("e0a56c"))
	draw_rect(Rect2(150, 16, 2, 7), Color("593a2d"))
	draw_rect(Rect2(169, 16, 2, 7), Color("593a2d"))


func _dibujar_tejido_pared() -> void:
	draw_rect(Rect2(72, 8, 39, 17), Color("3d292a"))
	draw_rect(Rect2(74, 9, 35, 14), Color("a13f39"))
	draw_rect(Rect2(74, 11, 35, 2), Color("e5ad72"))
	draw_rect(Rect2(74, 19, 35, 2), Color("e5ad72"))
	for x in [80, 89, 98]:
		draw_colored_polygon(PackedVector2Array([Vector2(x, 14), Vector2(x + 3, 17), Vector2(x, 20), Vector2(x - 3, 17)]), Color("f3d39b"))
		draw_rect(Rect2(x - 1, 16, 2, 2), Color("4b3134"))
	for x in range(76, 109, 4):
		draw_rect(Rect2(x, 23, 1, 3), Color("d8a16a"))


func _dibujar_tejido_suelo() -> void:
	# Rombos legibles a escala de juego, bajo los pies del jugador.
	draw_rect(Rect2(76, 62, 59, 48), Color("493033"))
	draw_rect(Rect2(78, 64, 55, 44), Color("af4e40"))
	draw_rect(Rect2(80, 66, 51, 40), Color("d29b62"))
	draw_rect(Rect2(82, 68, 47, 36), Color("7b3539"))
	for x in [92, 108, 124]:
		for y in [78, 94]:
			draw_colored_polygon(PackedVector2Array([Vector2(x, y - 6), Vector2(x + 6, y), Vector2(x, y + 6), Vector2(x - 6, y)]), Color("e9bc79"))
			draw_colored_polygon(PackedVector2Array([Vector2(x, y - 3), Vector2(x + 3, y), Vector2(x, y + 3), Vector2(x - 3, y)]), Color("365358"))
	for x in range(79, 134, 4):
		draw_rect(Rect2(x, 60, 1, 2), Color("c69d6d"))
		draw_rect(Rect2(x, 110, 1, 2), Color("c69d6d"))
