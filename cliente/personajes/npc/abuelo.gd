extends CharacterBody2D

const VELOCIDAD = 85.0
const ALTURA_VISIBLE = 27.0
const FPS_CAMINATA = 8.0
const TEXTURA_PERFIL: Texture2D = preload("res://cliente/sprites/npc/abuelo/perfil.png")
const TEXTURA_ARRIBA: Texture2D = preload("res://cliente/sprites/npc/abuelo/cuesta_arriba.png")
const TEXTURA_ABAJO: Texture2D = preload("res://cliente/sprites/npc/abuelo/cuesta_abajo.png")

# Las hojas reales son 1254x1254, pero sus filas no forman celdas uniformes.
# Estas bandas separan las 16 poses sin cortar los pies ni modificar los PNG.
const FILAS_PERFIL = [Vector2i(24, 320), Vector2i(336, 632), Vector2i(645, 943), Vector2i(958, 1248)]
const COLUMNAS_PERFIL = [Vector2i(82, 247), Vector2i(394, 568), Vector2i(705, 871), Vector2i(1023, 1185)]
const FILAS_ARRIBA = [Vector2i(43, 320), Vector2i(355, 632), Vector2i(666, 941), Vector2i(969, 1238)]
const COLUMNAS_ARRIBA = [Vector2i(72, 243), Vector2i(386, 559), Vector2i(699, 873), Vector2i(1013, 1184)]
const FILAS_ABAJO = [Vector2i(25, 321), Vector2i(342, 636), Vector2i(655, 939), Vector2i(952, 1237)]
const COLUMNAS_ABAJO = [Vector2i(105, 289), Vector2i(401, 582), Vector2i(675, 874), Vector2i(980, 1168)]

@export var controlable: bool = true
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var orientacion: StringName = &"abajo"


func _ready() -> void:
	var animaciones := SpriteFrames.new()
	animaciones.clear_all()
	_agregar_animaciones(animaciones, &"perfil", TEXTURA_PERFIL, FILAS_PERFIL, COLUMNAS_PERFIL)
	_agregar_animaciones(animaciones, &"arriba", TEXTURA_ARRIBA, FILAS_ARRIBA, COLUMNAS_ARRIBA)
	_agregar_animaciones(animaciones, &"abajo", TEXTURA_ABAJO, FILAS_ABAJO, COLUMNAS_ABAJO)
	sprite.sprite_frames = animaciones
	# El tamaño solo depende de la dirección, nunca del cuadro de la caminata.
	sprite.animation_changed.connect(_ajustar_frame)
	for accion in [["mover_izquierda", KEY_A], ["mover_derecha", KEY_D], ["mover_arriba", KEY_W], ["mover_abajo", KEY_S]]:
		if not InputMap.has_action(accion[0]):
			InputMap.add_action(accion[0])
		if InputMap.action_get_events(accion[0]).is_empty():
			var evento := InputEventKey.new()
			evento.physical_keycode = accion[1]
			InputMap.action_add_event(accion[0], evento)
	sprite.play(&"idle_abajo")
	_ajustar_frame()


func _agregar_animaciones(animaciones: SpriteFrames, nombre: StringName, textura: Texture2D, filas: Array, columnas: Array) -> void:
	var caminar := StringName("caminar_" + nombre)
	var idle := StringName("idle_" + nombre)
	animaciones.add_animation(caminar)
	animaciones.set_animation_speed(caminar, FPS_CAMINATA)
	animaciones.set_animation_loop(caminar, true)
	animaciones.add_animation(idle)
	animaciones.set_animation_speed(idle, 5.0)
	animaciones.set_animation_loop(idle, true)
	var imagen := textura.get_image()
	var cuadros: Array[AtlasTexture] = []
	var anclas: Array[float] = []
	var semiancho: float = 0.0
	var alto_lienzo: int = 0
	for fila: Vector2i in filas:
		for columna: Vector2i in columnas:
			var minimo := Vector2i(columna.y, fila.y)
			var maximo := Vector2i(columna.x, fila.x)
			# Se ignoran píxeles casi transparentes al medir el cuerpo visible.
			for y in range(fila.x, fila.y + 1):
				for x in range(columna.x, columna.y + 1):
					if imagen.get_pixel(x, y).a >= 0.5:
						minimo = Vector2i(mini(minimo.x, x), mini(minimo.y, y))
						maximo = Vector2i(maxi(maximo.x, x), maxi(maximo.y, y))
			var cuadro := AtlasTexture.new()
			cuadro.atlas = textura
			cuadro.region = Rect2(Vector2(minimo), Vector2(maximo - minimo + Vector2i.ONE))
			cuadro.filter_clip = true
			# El centro de la silueta completa cambia cuando una pierna se estira.
			# El sombrero ofrece un ancla estable sin quitar el movimiento de brazos/pies.
			var suma_x: float = 0.0
			var pixeles: int = 0
			var fin_sombrero := minimo.y + maxi(1, roundi(cuadro.region.size.y * 0.2))
			for y in range(minimo.y, fin_sombrero):
				for x in range(minimo.x, maximo.x + 1):
					if imagen.get_pixel(x, y).a >= 0.5:
						suma_x += x - minimo.x + 0.5
						pixeles += 1
			var ancla := roundf(suma_x / maxf(pixeles, 1.0))
			anclas.append(ancla)
			cuadros.append(cuadro)
			semiancho = maxf(semiancho, maxf(ancla, cuadro.region.size.x - ancla))
			alto_lienzo = maxi(alto_lienzo, roundi(cuadro.region.size.y))
	var ancho_lienzo := ceili(semiancho) * 2
	for i in range(cuadros.size()):
		var cuadro := cuadros[i]
		# Margin agrega espacio transparente virtual: no cambia ni estira el PNG.
		# Todos los cuadros mantienen el sombrero en la misma posición del lienzo.
		cuadro.margin = Rect2(
			Vector2(ancho_lienzo * 0.5 - anclas[i], 0),
			Vector2(ancho_lienzo, alto_lienzo) - cuadro.region.size
		)
		animaciones.add_frame(caminar, cuadro)
	animaciones.add_frame(idle, animaciones.get_frame_texture(caminar, 0))


func _physics_process(_delta: float) -> void:
	var direccion := Input.get_vector("mover_izquierda", "mover_derecha", "mover_arriba", "mover_abajo") if controlable else Vector2.ZERO
	velocity = direccion * VELOCIDAD
	move_and_slide()
	var caminando := velocity.length() > 1.0
	if caminando:
		if absf(velocity.x) > absf(velocity.y):
			orientacion = &"perfil"
			sprite.flip_h = velocity.x < 0.0
		else:
			orientacion = &"arriba" if velocity.y < 0.0 else &"abajo"
			sprite.flip_h = false
	var deseada := StringName(("caminar_" if caminando else "idle_") + orientacion)
	if sprite.animation != deseada or not sprite.is_playing():
		sprite.play(deseada)


func _ajustar_frame() -> void:
	var cuadro := sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	if cuadro == null:
		return
	var escala := ALTURA_VISIBLE / cuadro.get_height()
	sprite.scale = Vector2(escala, escala)
	# Lienzo estable apoyado en el origen; se conserva el movimiento natural de los pies.
	sprite.position = Vector2(0, -ALTURA_VISIBLE * 0.5)
