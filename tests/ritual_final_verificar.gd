extends SceneTree

const RitualFinalScript = preload("res://cliente/rituales/ritual_final.gd")
const JUEGO = preload("res://cliente/juego_local.tscn")


func _initialize() -> void:
	call_deferred("_probar")


func _tecla(codigo: Key) -> InputEventKey:
	var tecla := InputEventKey.new()
	tecla.keycode = codigo
	tecla.physical_keycode = codigo
	tecla.pressed = true
	return tecla


func _caso(lugar: String, piezas: Array, tierra: bool, agua: bool, resultado: Array, tipo_agua: String = "") -> void:
	var ritual = RitualFinalScript.new()
	ritual.lugar_correcto = lugar
	ritual.tierra_correcta = tierra
	ritual.agua_correcta = agua
	ritual.tipo_agua = tipo_agua
	var recibido: Array = []
	ritual.finalizado.connect(func(ajayu: bool, lluvia: bool): recibido.append([ajayu, lluvia]))
	root.add_child(ritual)
	ritual._input(_tecla(KEY_E))
	assert(ritual.fase == &"miniatura")
	ritual._input(_tecla(KEY_ENTER))
	assert(ritual.fase == &"miniatura")
	for indice in range(3):
		ritual._input(_tecla(KEY_1 + indice))
		assert(ritual.menu_piezas.text.contains(">%d" % (indice + 1)))
		for paso in range(piezas[indice]):
			var texto_anterior: String = ritual.menu_piezas.text
			ritual._input(_tecla(KEY_RIGHT))
			assert(ritual.menu_piezas.text != texto_anterior)
	ritual._input(_tecla(KEY_ENTER))
	assert(ritual.fase == &"lavar")
	ritual._input(_tecla(KEY_E))
	assert(ritual.fase == &"frotar")
	ritual._input(_tecla(KEY_E))
	assert(ritual.fase == &"perro")
	ritual._input(_tecla(KEY_E))
	assert(ritual.fase == &"resultado")
	if not tipo_agua.is_empty():
		assert(ritual.escena_clima.visible)
		assert(ritual.escena_clima.get_child_count() == 1)
		var palabra: String = {"jallu": "Llueve", "chhijchi": "granizo", "juyphi": "helada"}[tipo_agua]
		assert(ritual.relato.text.contains(palabra))
	ritual._input(_tecla(KEY_E))
	assert(recibido == [resultado])
	print("OK: miniatura=", piezas, ", tierra=", tierra, ", agua=", agua, " -> ", recibido)
	await process_frame
	await process_frame


func _probar() -> void:
	await _caso("roqueria_alta", [2, 2, 3], true, true, [true, true], "jallu")
	await _caso("roqueria_alta", [1, 3, 2], true, true, [false, true])
	await _caso("roqueria_alta", [2, 2, 3], true, false, [true, false], "chhijchi")
	await _caso("roqueria_alta", [2, 2, 3], true, false, [true, false], "juyphi")
	await _caso("roqueria_alta", [1, 3, 2], true, false, [false, false])
	await _caso("quebrada_media", [1, 3, 2], false, true, [false, true])
	await _caso("quebrada_media", [1, 3, 2], true, true, [true, true])
	await _caso("paso_ladera_alta", [3, 1, 1], true, true, [true, true])
	var ritual = RitualFinalScript.new()
	var cancelado: Array = []
	ritual.cancelado.connect(func(): cancelado.append(true))
	root.add_child(ritual)
	ritual._input(_tecla(KEY_ESCAPE))
	assert(cancelado.size() == 1)
	await process_frame
	await process_frame
	var ciclo = RitualFinalScript.new()
	root.add_child(ciclo)
	ciclo._input(_tecla(KEY_E))
	ciclo._input(_tecla(KEY_LEFT))
	assert(ciclo.piezas[0] == 3)
	ciclo._input(_tecla(KEY_RIGHT))
	assert(ciclo.piezas[0] == 1)
	ciclo._input(_tecla(KEY_LEFT))
	assert(ciclo.piezas[0] == 3)
	ciclo.queue_free()
	await process_frame
	var juego := JUEGO.instantiate()
	root.add_child(juego)
	root.push_input(_tecla(KEY_ENTER))
	await process_frame
	var pueblo: Node = juego.escenario_actual
	assert(pueblo.name == "Pueblo")
	pueblo.get_node("Introduccion").finalizar()
	var mision: Node = pueblo.get_child(pueblo.get_child_count() - 1)
	mision._iniciar_ritual()
	root.push_input(_tecla(KEY_E))
	await process_frame
	assert(mision.ritual.fase == &"miniatura")
	var texto_anterior: String = mision.ritual.menu_piezas.text
	root.push_input(_tecla(KEY_RIGHT))
	await process_frame
	assert(mision.ritual.piezas[0] == 1)
	assert(mision.ritual.menu_piezas.text != texto_anterior)
	print("OK: flecha derecha real actualiza la miniatura en juego_local")
	quit()
