extends CharacterBody2D

const VELOCIDAD = 150.0
const COLUMNAS_SPRITESHEET = 4
const FILAS_SPRITESHEET = 4
const FPS_CAMINATA = 12.0
const ALTURA_VISIBLE_OBJETIVO = 27.0
const ALTURA_VISIBLE_ABAJO = 364.56
const ALTURA_VISIBLE_ARRIBA = 308.25
const ALTURA_VISIBLE_PERFIL = 246.12

const TEXTURA_CUESTA_ABAJO: Texture2D = preload("res://cliente/sprites/caminante/cuesta_abajo.png")
const TEXTURA_CUESTA_ARRIBA: Texture2D = preload("res://cliente/sprites/caminante/cuesta_arriba.png")
const TEXTURA_PERFIL: Texture2D = preload("res://cliente/sprites/caminante/perfil.png")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var ultima_orientacion: StringName = &"abajo"


func _ready() -> void:
	_configurar_animaciones()
	_registrar_accion_si_falta("mover_izquierda", KEY_A)
	_registrar_accion_si_falta("mover_derecha", KEY_D)
	_registrar_accion_si_falta("mover_arriba", KEY_W)
	_registrar_accion_si_falta("mover_abajo", KEY_S)
	_aplicar_escala(&"abajo")
	animated_sprite.play(&"idle_abajo")


func _configurar_animaciones() -> void:
	var animaciones := SpriteFrames.new()
	animaciones.clear_all()

	_agregar_animacion(animaciones, &"caminar_abajo", TEXTURA_CUESTA_ABAJO)
	_agregar_animacion(animaciones, &"caminar_arriba", TEXTURA_CUESTA_ARRIBA)
	_agregar_animacion(animaciones, &"caminar_lateral", TEXTURA_PERFIL)
	_agregar_idle(animaciones, &"idle_abajo", TEXTURA_CUESTA_ABAJO)
	_agregar_idle(animaciones, &"idle_arriba", TEXTURA_CUESTA_ARRIBA)
	_agregar_idle(animaciones, &"idle_lateral", TEXTURA_PERFIL)

	animated_sprite.sprite_frames = animaciones


func _agregar_animacion(animaciones: SpriteFrames, nombre: StringName, textura: Texture2D) -> void:
	animaciones.add_animation(nombre)
	animaciones.set_animation_loop(nombre, true)
	animaciones.set_animation_speed(nombre, FPS_CAMINATA)

	for fila in range(FILAS_SPRITESHEET):
		for columna in range(COLUMNAS_SPRITESHEET):
			animaciones.add_frame(nombre, _crear_frame(textura, columna, fila))


func _agregar_idle(animaciones: SpriteFrames, nombre: StringName, textura: Texture2D) -> void:
	animaciones.add_animation(nombre)
	animaciones.set_animation_loop(nombre, true)
	animaciones.set_animation_speed(nombre, 5.0)
	animaciones.add_frame(nombre, _crear_frame(textura, 0, 0))


func _crear_frame(textura: Texture2D, columna: int, fila: int) -> AtlasTexture:
	var x_inicial := roundi(float(textura.get_width()) * columna / COLUMNAS_SPRITESHEET)
	var x_final := roundi(float(textura.get_width()) * (columna + 1) / COLUMNAS_SPRITESHEET)
	var y_inicial := roundi(float(textura.get_height()) * fila / FILAS_SPRITESHEET)
	var y_final := roundi(float(textura.get_height()) * (fila + 1) / FILAS_SPRITESHEET)

	var frame := AtlasTexture.new()
	frame.atlas = textura
	frame.region = Rect2(x_inicial, y_inicial, x_final - x_inicial, y_final - y_inicial)
	return frame


func _registrar_accion_si_falta(nombre: StringName, tecla: Key) -> void:
	if not InputMap.has_action(nombre):
		InputMap.add_action(nombre)
	if not InputMap.action_get_events(nombre).is_empty():
		return

	var evento := InputEventKey.new()
	evento.keycode = tecla
	evento.physical_keycode = tecla
	InputMap.action_add_event(nombre, evento)


func _physics_process(_delta: float) -> void:
	var direccion := Input.get_vector("mover_izquierda", "mover_derecha", "mover_arriba", "mover_abajo")
	var direccion_iso := direccion.normalized() if direccion != Vector2.ZERO else Vector2.ZERO
	velocity = direccion_iso * VELOCIDAD
	move_and_slide()

	var esta_moviendose := Vector2(velocity.x, velocity.y).length() > 10.0
	if esta_moviendose:
		_actualizar_orientacion()

	var animacion_deseada := _obtener_animacion(esta_moviendose)
	if animated_sprite.animation != animacion_deseada or not animated_sprite.is_playing():
		animated_sprite.play(animacion_deseada)


func _actualizar_orientacion() -> void:
	var nueva_orientacion: StringName
	if absf(velocity.x) > absf(velocity.y):
		nueva_orientacion = &"lateral"
		animated_sprite.flip_h = velocity.x < 0.0
	elif velocity.y < 0.0:
		nueva_orientacion = &"arriba"
		animated_sprite.flip_h = false
	else:
		nueva_orientacion = &"abajo"
		animated_sprite.flip_h = false

	if nueva_orientacion != ultima_orientacion:
		ultima_orientacion = nueva_orientacion
		_aplicar_escala(ultima_orientacion)


func _obtener_animacion(esta_moviendose: bool) -> StringName:
	match ultima_orientacion:
		&"arriba":
			return &"caminar_arriba" if esta_moviendose else &"idle_arriba"
		&"lateral":
			return &"caminar_lateral" if esta_moviendose else &"idle_lateral"
		_:
			return &"caminar_abajo" if esta_moviendose else &"idle_abajo"


func _aplicar_escala(orientacion: StringName) -> void:
	var altura_original := ALTURA_VISIBLE_ABAJO
	if orientacion == &"arriba":
		altura_original = ALTURA_VISIBLE_ARRIBA
	elif orientacion == &"lateral":
		altura_original = ALTURA_VISIBLE_PERFIL

	var escala := ALTURA_VISIBLE_OBJETIVO / altura_original
	animated_sprite.scale = Vector2(escala, escala)
