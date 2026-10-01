extends CharacterBody2D

const IDLE = preload("res://cliente/sprites/perro/Golden-Retriever-idle.png")
const CAMINAR = preload("res://cliente/sprites/perro/Golden-Retriever-walk.png")
const CORRER = preload("res://cliente/sprites/perro/Golden-Retriever-run.png")
const SENTADO = preload("res://cliente/sprites/perro/Golden-Retriever-sitting.png")
const ACOSTARSE = preload("res://cliente/sprites/perro/Golden-Retriever-lying-down.png")
const DORMIR = preload("res://cliente/sprites/perro/Golden-Retriever-sleeping.png")
const LADRAR = preload("res://cliente/sprites/perro/Golden-Retriever-bark.png")
const ESTIRARSE = preload("res://cliente/sprites/perro/Golden-Retriever-stretching.png")
const RASCARSE = preload("res://cliente/sprites/perro/Golden-Retriever-itching.png")
const LAMER_1 = preload("res://cliente/sprites/perro/Golden-Retriever-licking1.png")
const LAMER_2 = preload("res://cliente/sprites/perro/Golden-Retriever-licking2.png")

const LADO_CUADRO = 100
const DISTANCIA_INICIAR = 25.0
const DISTANCIA_DETENER = 13.0
const VELOCIDAD_SEGUIR = 125.0
const VELOCIDAD_CORRER = 175.0
const TAMANO_CELDA = 12
const MARGEN_RUTA = 12
const INTERVALO_RUTA = 0.65

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var objetivo: Node2D
var siguiendo: bool = false
var ultima_direccion: Vector2 = Vector2.RIGHT
var ruta: Array[Vector2] = []
var tiempo_ruta: float = 0.0
var quieto_por: float = 0.0
var tiempo_accion: float = 0.0
var rng := RandomNumberGenerator.new()
var sentado_fijo: bool = false


func _ready() -> void:
	rng.randomize()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.sprite_frames = SpriteFrames.new()
	if sprite.sprite_frames.has_animation("default"):
		sprite.sprite_frames.remove_animation("default")
	_agregar("idle", IDLE, 10, 6.0, true)
	_agregar("caminar", CAMINAR, 8, 9.0, true)
	_agregar("correr", CORRER, 8, 12.0, true)
	_agregar("sentado", SENTADO, 1, 1.0, true)
	_agregar("acostarse", ACOSTARSE, 7, 7.0, false)
	_agregar("dormir", DORMIR, 1, 1.0, true)
	_agregar("ladrar", LADRAR, 3, 6.0, false)
	_agregar("estirarse", ESTIRARSE, 10, 8.0, false)
	_agregar("rascarse", RASCARSE, 2, 4.0, false)
	_agregar("lamer_1", LAMER_1, 4, 5.0, false)
	_agregar("lamer_2", LAMER_2, 4, 5.0, false)
	sprite.play("idle")
	tiempo_accion = rng.randf_range(2.0, 4.0)


func _agregar(nombre: String, hoja: Texture2D, cantidad: int, fps: float, bucle: bool) -> void:
	sprite.sprite_frames.add_animation(nombre)
	sprite.sprite_frames.set_animation_speed(nombre, fps)
	sprite.sprite_frames.set_animation_loop(nombre, bucle)
	for indice in range(cantidad):
		var cuadro := AtlasTexture.new()
		cuadro.atlas = hoja
		cuadro.region = Rect2(indice * LADO_CUADRO, 0, LADO_CUADRO, LADO_CUADRO)
		cuadro.filter_clip = true
		sprite.sprite_frames.add_frame(nombre, cuadro)


func seguir_a(personaje: Node2D) -> void:
	objetivo = personaje
	sentado_fijo = false
	siguiendo = false
	ultima_direccion = Vector2.RIGHT
	ruta.clear()
	global_position = (objetivo.global_position + Vector2(-19, -4)).round()
	if objetivo is PhysicsBody2D:
		add_collision_exception_with(objetivo)
	sprite.play("idle")


func quedarse_sentado(posicion: Vector2) -> void:
	objetivo = null
	sentado_fijo = true
	siguiendo = false
	ruta.clear()
	velocity = Vector2.ZERO
	global_position = posicion.round()
	sprite.play("sentado")


func _physics_process(delta: float) -> void:
	if sentado_fijo or not is_instance_valid(objetivo):
		return
	var jugador_moviendose: bool = objetivo is CharacterBody2D and (objetivo as CharacterBody2D).velocity.length() > 10.0
	if jugador_moviendose:
		ultima_direccion = objetivo.velocity.normalized()
	# Un leve sesgo hacia arriba lo deja detrás del jugador al caminar de lado.
	# En subida/bajada manda el orden real de Y de los dos personajes.
	var destino := objetivo.global_position - ultima_direccion * 20.0 + Vector2(0, -4)
	var distancia := global_position.distance_to(destino)
	if not siguiendo and distancia > DISTANCIA_INICIAR:
		siguiendo = true
	elif siguiendo and distancia < DISTANCIA_DETENER:
		siguiendo = false
	if siguiendo:
		_seguir_destino(destino, delta)
	else:
		velocity = Vector2.ZERO
		ruta.clear()
		_animar_reposo(delta, jugador_moviendose)


func _seguir_destino(destino: Vector2, delta: float) -> void:
	quieto_por = 0.0
	tiempo_ruta -= delta
	var espacio := get_world_2d().direct_space_state
	var consulta := PhysicsRayQueryParameters2D.create(global_position, destino, collision_mask, [get_rid(), objetivo.get_rid()])
	var obstruido := not espacio.intersect_ray(consulta).is_empty()
	if not obstruido:
		ruta.clear()
	else:
		if ruta.is_empty() or tiempo_ruta <= 0.0:
			_calcular_ruta(destino)
			tiempo_ruta = INTERVALO_RUTA
	if obstruido and ruta.is_empty():
		velocity = Vector2.ZERO
		if sprite.animation != &"idle":
			sprite.play("idle")
		return
	while not ruta.is_empty() and global_position.distance_to(ruta[0]) < 7.0:
		ruta.remove_at(0)
	var punto := ruta[0] if not ruta.is_empty() else destino
	var direccion := global_position.direction_to(punto)
	var corriendo := global_position.distance_to(destino) > 80.0
	velocity = direccion * (VELOCIDAD_CORRER if corriendo else VELOCIDAD_SEGUIR)
	move_and_slide()
	if absf(velocity.x) > 1.0:
		sprite.flip_h = velocity.x < 0.0
	var animacion: StringName = &"correr" if corriendo else &"caminar"
	if sprite.animation != animacion:
		sprite.play(animacion)


func _calcular_ruta(destino: Vector2) -> void:
	ruta.clear()
	var inicio := Vector2i(floori(global_position.x / TAMANO_CELDA), floori(global_position.y / TAMANO_CELDA))
	var fin := Vector2i(floori(destino.x / TAMANO_CELDA), floori(destino.y / TAMANO_CELDA))
	var minimo := Vector2i(mini(inicio.x, fin.x), mini(inicio.y, fin.y)) - Vector2i(MARGEN_RUTA, MARGEN_RUTA)
	var maximo := Vector2i(maxi(inicio.x, fin.x), maxi(inicio.y, fin.y)) + Vector2i(MARGEN_RUTA, MARGEN_RUTA)
	var grilla := AStarGrid2D.new()
	grilla.region = Rect2i(minimo, maximo - minimo + Vector2i.ONE)
	grilla.cell_size = Vector2(TAMANO_CELDA, TAMANO_CELDA)
	grilla.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	grilla.update()
	var forma := RectangleShape2D.new()
	forma.size = Vector2(10, 8)
	var parametros := PhysicsShapeQueryParameters2D.new()
	parametros.shape = forma
	parametros.collision_mask = collision_mask
	parametros.exclude = [get_rid(), objetivo.get_rid()]
	var espacio := get_world_2d().direct_space_state
	for y in range(minimo.y, maximo.y + 1):
		for x in range(minimo.x, maximo.x + 1):
			var celda := Vector2i(x, y)
			if celda == inicio or celda == fin:
				continue
			parametros.transform = Transform2D(0.0, (Vector2(celda) + Vector2(0.5, 0.5)) * TAMANO_CELDA)
			if not espacio.intersect_shape(parametros, 1).is_empty():
				grilla.set_point_solid(celda)
	var celdas := grilla.get_id_path(inicio, fin)
	for indice in range(1, celdas.size()):
		ruta.append((Vector2(celdas[indice]) + Vector2(0.5, 0.5)) * TAMANO_CELDA)


func _animar_reposo(delta: float, jugador_moviendose: bool) -> void:
	if jugador_moviendose:
		quieto_por = 0.0
		tiempo_accion = rng.randf_range(2.0, 4.0)
		if sprite.animation != &"idle":
			sprite.play("idle")
		return
	quieto_por += delta
	if quieto_por < 1.5:
		if sprite.animation != &"idle":
			sprite.play("idle")
		return
	tiempo_accion -= delta
	if tiempo_accion > 0.0:
		if sprite.animation == &"acostarse" and not sprite.is_playing():
			sprite.play("dormir")
		return
	var acciones: Array[StringName] = [&"idle", &"sentado", &"acostarse", &"ladrar", &"estirarse", &"rascarse", &"lamer_1", &"lamer_2"]
	var accion: StringName = acciones[rng.randi_range(0, acciones.size() - 1)]
	sprite.play(accion)
	tiempo_accion = rng.randf_range(3.0, 6.0)
