extends SceneTree

const PerroEscena = preload("res://cliente/personajes/npc/perro.tscn")
const PuebloEscena = preload("res://cliente/niveles/pueblo/pueblo.tscn")
const CerroEscena = preload("res://cliente/niveles/cerro/cerro_clip2.tscn")


func _initialize() -> void:
	call_deferred("_probar")


func _probar() -> void:
	var pueblo = PuebloEscena.instantiate()
	assert(pueblo.get_node("Node2D").y_sort_enabled)
	pueblo.free()
	var cerro = CerroEscena.instantiate()
	assert(cerro.get_node("Entidades").y_sort_enabled)
	cerro.free()
	var escenario := Node2D.new()
	root.add_child(escenario)
	var jugador := CharacterBody2D.new()
	jugador.position = Vector2(100, 100)
	escenario.add_child(jugador)
	var perro = PerroEscena.instantiate()
	escenario.add_child(perro)
	perro.seguir_a(jugador)
	var sprite := perro.get_node("AnimatedSprite2D") as AnimatedSprite2D
	assert(sprite.position.y == 6.0)
	assert(perro is CharacterBody2D)
	assert(perro.collision_mask == 1 and perro.collision_layer == 0)
	assert(sprite.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST)
	assert(sprite.sprite_frames.get_frame_count("idle") == 10)
	assert(sprite.sprite_frames.get_frame_count("caminar") == 8)
	assert(sprite.sprite_frames.get_frame_count("sentado") == 1)
	assert(sprite.sprite_frames.get_frame_count("acostarse") == 7)
	jugador.position = Vector2(170, 100)
	jugador.velocity = Vector2(100, 0)
	for indice in range(30):
		await physics_frame
	assert(perro.global_position.distance_to(Vector2(150, 96)) < 15.0)
	assert(sprite.animation in [&"caminar", &"idle"])
	jugador.velocity = Vector2.ZERO
	perro.quieto_por = 2.0
	perro.tiempo_accion = 0.0
	await physics_frame
	assert(sprite.animation in [&"idle", &"sentado", &"acostarse", &"ladrar", &"estirarse", &"rascarse", &"lamer_1", &"lamer_2"])
	perro.global_position = Vector2(100, 160)
	jugador.global_position = Vector2(100, 100)
	jugador.velocity = Vector2.UP * 100.0
	for indice in range(60):
		await physics_frame
	assert(perro.global_position.y > jugador.global_position.y, "Al subir, el perro debe quedar delante")
	jugador.velocity = Vector2.DOWN * 100.0
	for indice in range(60):
		await physics_frame
	assert(perro.global_position.y < jugador.global_position.y, "Al bajar, el jugador debe quedar delante")
	perro.quedarse_sentado(Vector2(200, 180))
	assert(perro.objetivo == null)
	assert(sprite.animation == &"sentado")
	assert(perro.global_position == Vector2(200, 180))
	var pared := StaticBody2D.new()
	pared.position = Vector2(145, 200)
	escenario.add_child(pared)
	var forma_pared := CollisionShape2D.new()
	var rectangulo := RectangleShape2D.new()
	rectangulo.size = Vector2(10, 60)
	forma_pared.shape = rectangulo
	pared.add_child(forma_pared)
	perro.seguir_a(jugador)
	perro.global_position = Vector2(100, 200)
	jugador.global_position = Vector2(190, 200)
	jugador.velocity = Vector2.ZERO
	for indice in range(240):
		await physics_frame
		assert(not Rect2(Vector2(135, 166), Vector2(20, 68)).has_point(perro.global_position))
	assert(perro.global_position.x > 155.0, "El perro debe rodear la pared para llegar al jugador")
	print("OK: cuadros, seguimiento, colisiones, acciones y orden por profundidad del perro")
	quit()
