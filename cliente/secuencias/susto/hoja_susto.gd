extends RefCounted

const TEXTURA: Texture2D = preload("res://cliente/sprites/npc/abuelo/susto_caida.png")
const FILAS = [Vector2i(49,375),Vector2i(411,710),Vector2i(795,955),Vector2i(1081,1213)]
const COLUMNAS = [
	[Vector2i(94,231),Vector2i(396,571),Vector2i(703,879),Vector2i(1004,1207)],
	[Vector2i(43,295),Vector2i(340,604),Vector2i(635,909),Vector2i(942,1238)],
	[Vector2i(25,319),Vector2i(329,620),Vector2i(630,927),Vector2i(942,1237)],
	[Vector2i(12,309),Vector2i(322,619),Vector2i(635,931),Vector2i(948,1242)]
]
const ESCALA = 27.0 / 326.0
const LIENZO = Vector2(320,334)


static func crear_frames() -> SpriteFrames:
	var imagen := TEXTURA.get_image()
	if imagen == null or imagen.get_size() != Vector2i(1254,1254):
		push_error("La hoja de susto cambió de tamaño; revisar los recortes antes de reproducirla.")
		return null
	var cuadros: Array[AtlasTexture] = []
	for fila in range(4):
		for columna in range(4):
			var horizontal: Vector2i = COLUMNAS[fila][columna]
			var vertical: Vector2i = FILAS[fila]
			var desde := Vector2i(maxi(horizontal.x-4,0),maxi(vertical.x-4,0))
			var hasta := Vector2i(mini(horizontal.y+4,1254),mini(vertical.y+4,1254))
			var cuadro := AtlasTexture.new()
			cuadro.atlas = TEXTURA
			cuadro.region = Rect2(Vector2(desde),Vector2(hasta-desde))
			cuadro.margin = Rect2(Vector2((LIENZO.x-cuadro.region.size.x)*0.5,LIENZO.y-cuadro.region.size.y),LIENZO-cuadro.region.size)
			cuadro.filter_clip = true
			cuadros.append(cuadro)
	var frames := SpriteFrames.new()
	frames.clear_all()
	for definicion in [["susto",0,4,7.0,false],["caida",4,12,10.0,false],["caido",12,16,4.0,true]]:
		var nombre := StringName(definicion[0])
		frames.add_animation(nombre)
		frames.set_animation_loop(nombre,definicion[4])
		frames.set_animation_speed(nombre,definicion[3])
		for indice in range(definicion[1],definicion[2]):
			frames.add_frame(nombre,cuadros[indice])
	return frames
