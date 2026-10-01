extends SceneTree

const JUEGO = preload("res://cliente/juego_local.tscn")


func _initialize() -> void:
	call_deferred("_probar")


func _probar() -> void:
	var juego := JUEGO.instantiate()
	root.add_child(juego)
	var cerro: Node2D = juego.escenario_actual
	assert(cerro.get_node("Guia/Ayuda").text.contains("Enter: omitir"))
	assert(cerro.get_node("ZonaSusto/NombreClaro").text == cerro.nombre_lugar_susto.capitalize())
	var tecla := InputEventKey.new()
	tecla.keycode = KEY_ENTER
	tecla.pressed = true
	root.push_input(tecla)
	await process_frame
	assert(not juego.en_prologo)
	assert(juego.escenario_actual.name == "Pueblo")
	juego.queue_free()
	await process_frame

	var recorrido := JUEGO.instantiate()
	root.add_child(recorrido)
	var cerro_recorrido: Node2D = recorrido.escenario_actual
	cerro_recorrido.abuelo.global_position = cerro_recorrido.get_node("ZonaSusto").global_position
	for i in range(4):
		await process_frame
	assert(cerro_recorrido.evento.estado == &"reproduciendo")
	assert(cerro_recorrido.evento.nanqha.visible)
	assert(cerro_recorrido.evento.nanqha.z_index == 5)
	await create_timer(11.0).timeout
	assert(recorrido.escenario_actual.name == "Pueblo")
	print("Prólogo: destino visible, omisión a pueblo, Ñanqha y transición normal a pueblo OK")
	quit()
