@tool
extends Node2D

const TEXTURA: Texture2D = preload("res://cliente/sprites/enemigos/nanqha/aparicion_idle.png")
const FILAS = [Vector2i(0,336),Vector2i(336,636),Vector2i(636,931),Vector2i(931,1254)]
const COLUMNAS = [0,314,627,941,1254]
const ALTURA_VISIBLE = 40.0
const ALTURA_REFERENCIA = 288.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var estado: StringName = &"idle"


func _ready() -> void:
	_configurar_animaciones()
	sprite.animation_finished.connect(_al_terminar_animacion)
	sprite.play(&"idle")


func _configurar_animaciones() -> void:
	var imagen := TEXTURA.get_image()
	if imagen == null or imagen.get_size() != Vector2i(1254,1254):
		push_error("La hoja de Nanqha cambió de tamaño; revisar las bandas antes de recortarla.")
		return
	var cuadros: Array[AtlasTexture] = []
	var anclas: Array[float] = []
	var semiancho := 0.0
	var alto := 0
	for fila: Vector2i in FILAS:
		for columna in range(4):
			var minimo := Vector2i(COLUMNAS[columna+1],fila.y)
			var maximo := Vector2i(COLUMNAS[columna],fila.x)
			for y in range(fila.x,fila.y):
				for x in range(COLUMNAS[columna],COLUMNAS[columna+1]):
					if imagen.get_pixel(x,y).a >= 0.5:
						minimo = Vector2i(mini(minimo.x,x),mini(minimo.y,y))
						maximo = Vector2i(maxi(maximo.x,x),maxi(maximo.y,y))
			# Margen pequeño para conservar el humo, sin invadir las filas contiguas.
			var desde := Vector2i(maxi(minimo.x-3,COLUMNAS[columna]),maxi(minimo.y-3,fila.x))
			var hasta := Vector2i(mini(maximo.x+4,COLUMNAS[columna+1]),mini(maximo.y+4,fila.y))
			var cuadro := AtlasTexture.new()
			cuadro.atlas = TEXTURA
			cuadro.region = Rect2(Vector2(desde),Vector2(hasta-desde))
			cuadro.filter_clip = true
			# La cabeza ancla el idle; el centro de la nube cambia al moverse su cola.
			var suma_x := 0.0
			var cantidad := 0
			var fin_ancla := mini(maximo.y+1,minimo.y+maxi(1,roundi((maximo.y-minimo.y+1)*0.25)))
			for y in range(minimo.y,fin_ancla):
				for x in range(minimo.x,maximo.x+1):
					if imagen.get_pixel(x,y).a >= 0.5:
						suma_x += x-desde.x+0.5
						cantidad += 1
			var ancla := roundf(suma_x/maxf(cantidad,1.0))
			anclas.append(ancla)
			cuadros.append(cuadro)
			semiancho = maxf(semiancho,maxf(ancla,cuadro.region.size.x-ancla))
			alto = maxi(alto,roundi(cuadro.region.size.y))
	var ancho := ceili(semiancho)*2
	for i in range(cuadros.size()):
		var cuadro := cuadros[i]
		cuadro.margin = Rect2(Vector2(ancho*0.5-anclas[i],alto-cuadro.region.size.y),Vector2(ancho,alto)-cuadro.region.size)
	var frames := SpriteFrames.new()
	frames.clear_all()
	frames.add_animation(&"aparicion")
	frames.set_animation_loop(&"aparicion",false)
	frames.set_animation_speed(&"aparicion",8.0)
	frames.add_animation(&"idle")
	frames.set_animation_loop(&"idle",true)
	frames.set_animation_speed(&"idle",6.0)
	for i in range(16):
		frames.add_frame(&"aparicion" if i < 8 else &"idle",cuadros[i])
	sprite.sprite_frames = frames
	var escala := ALTURA_VISIBLE/ALTURA_REFERENCIA
	sprite.scale = Vector2.ONE*escala
	sprite.position = Vector2(0,-alto*escala*0.5)


func aparecer(duracion: float = 1.1) -> void:
	estado = &"apareciendo"
	show()
	sprite.stop()
	sprite.speed_scale = 1.0/maxf(duracion,0.05)
	sprite.play(&"aparicion")
	sprite.frame = 0


func desvanecer(duracion: float = 1.0) -> void:
	estado = &"desapareciendo"
	sprite.stop()
	sprite.speed_scale = 1.0/maxf(duracion,0.05)
	sprite.play_backwards(&"aparicion")
	sprite.frame = 7


func _al_terminar_animacion() -> void:
	if estado == &"apareciendo":
		estado = &"idle"
		sprite.speed_scale = 1.0
		sprite.play(&"idle")
	elif estado == &"desapareciendo":
		estado = &"oculta"
		sprite.speed_scale = 1.0
		hide()
