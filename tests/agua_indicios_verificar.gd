extends SceneTree

const JUEGO = preload("res://cliente/juego_local.tscn")
const LecturaAgua = preload("res://cliente/misiones/lectura_agua.gd")
const LUGARES = ["roqueria_alta", "quebrada_media", "paso_ladera_alta"]
const TIERRAS = {
	"roqueria_alta": "HitosCerro/TierraRoqueria",
	"quebrada_media": "HitosCerro/TierraQuebrada",
	"paso_ladera_alta": "HitosCerro/TierraPasoAlto"
}


func _initialize() -> void:
	call_deferred("_probar")


func _tecla(codigo: Key) -> InputEventKey:
	var tecla := InputEventKey.new()
	tecla.keycode = codigo
	tecla.physical_keycode = codigo
	tecla.pressed = true
	return tecla


func _interactuar(mision: Node, jugador: CharacterBody2D, destino: Node2D) -> void:
	jugador.global_position = destino.global_position
	mision._unhandled_input(_tecla(KEY_E))


func _probar() -> void:
	for tipo in LecturaAgua.TIPOS:
		var respuesta: Array = LecturaAgua.RESPUESTAS[tipo]
		assert(LecturaAgua.evaluar(tipo, respuesta)["calidad"] == "clara")
		assert(LecturaAgua.evaluar(tipo, [respuesta[0], respuesta[1], 0, 0, 0])["calidad"] == "dudosa")
		assert(LecturaAgua.evaluar(tipo, [0, 0, 0, 0, 0])["calidad"] == "incompleta")
		var otro: Array = LecturaAgua.RESPUESTAS[LecturaAgua.TIPOS[(LecturaAgua.TIPOS.find(tipo) + 1) % 3]]
		assert(LecturaAgua.evaluar(tipo, otro)["calidad"] == "contradictoria")
	for indice in range(3):
		var juego = JUEGO.instantiate()
		root.add_child(juego)
		juego.partida["lugar_correcto"] = LUGARES[indice]
		juego.partida["pozo_jallu_uma"] = "pozo_%d" % (indice + 1)
		juego._mostrar_pueblo(false)
		var pueblo = juego.escenario_actual
		pueblo.get_node("Introduccion").finalizar()
		var mision_pueblo = pueblo.get_child(pueblo.get_child_count() - 1)
		var jugador := pueblo.get_node("Node2D/Jugador") as CharacterBody2D
		assert(mision_pueblo.en_casa)
		assert(mision_pueblo.casa.get_node("Camera2D").is_current())
		var cama := pueblo.get_node("Node2D/FamiliaPrologo/Abuelo/Cama") as Sprite2D
		assert(cama.texture.resource_path == "res://cliente/tiles_raw/interiores/tileset_bed.png")
		assert(pueblo.get_node("Node2D/CasaAbuelo/Muros/Canasto") is CollisionShape2D)
		assert(pueblo.get_node("Node2D/CasaAbuelo/Muros/MesaBaja") is CollisionShape2D)
		jugador.global_position = mision_pueblo.puerta_interior.global_position
		mision_pueblo._unhandled_input(_tecla(KEY_E))
		assert(not mision_pueblo.en_casa)
		assert(not mision_pueblo.familia.visible)
		assert(jugador.get_node("Camera2D").is_current())
		jugador.position = Vector2(220, 116)
		mision_pueblo._unhandled_input(_tecla(KEY_E))
		assert(mision_pueblo.fase == &"prenda")
		jugador.global_position = mision_pueblo.puerta_exterior.global_position
		mision_pueblo._unhandled_input(_tecla(KEY_E))
		assert(mision_pueblo.en_casa)
		assert(mision_pueblo.familia.visible)
		assert(mision_pueblo.casa.get_node("Camera2D").is_current())
		jugador.global_position = mision_pueblo.abuelo.global_position
		mision_pueblo._unhandled_input(_tecla(KEY_E))
		assert(mision_pueblo.fase == &"salida")
		jugador.global_position = mision_pueblo.puerta_interior.global_position
		mision_pueblo._unhandled_input(_tecla(KEY_E))
		assert(not mision_pueblo.en_casa)
		jugador.position = Vector2(70, 130)
		mision_pueblo._unhandled_input(_tecla(KEY_E))
		var cerro = juego.escenario_actual
		var mision = cerro.get_child(cerro.get_child_count() - 1)
		jugador = cerro.get_node("Entidades/Jugador") as CharacterBody2D
		assert(mision._tipo_pozo("pozo_%d" % (indice + 1)) == "jallu")
		var tipos := []
		for numero in range(1, 4):
			tipos.append(mision._tipo_pozo("pozo_%d" % numero))
		assert(tipos.has("chhijchi") and tipos.has("juyphi"))
		var pozo_malo := (indice + 1) % 3 + 1
		_interactuar(mision, jugador, cerro.get_node("HitosCerro/Pozo%d" % pozo_malo))
		assert(mision.panel_senas.visible)
		assert(mision.agua_recogida.is_empty())
		assert(mision.pozos_observados.has("pozo_%d" % pozo_malo))
		mision._input(_tecla(KEY_R))
		assert(mision.modo_panel == &"editor")
		var respuesta_mala: Array = LecturaAgua.RESPUESTAS[mision._tipo_pozo("pozo_%d" % pozo_malo)]
		for rasgo in range(5):
			mision._input(_tecla(KEY_1 + rasgo))
			for paso in range(respuesta_mala[rasgo]):
				mision._input(_tecla(KEY_RIGHT))
		mision._input(_tecla(KEY_ENTER))
		assert(mision.descriptores_elegidos["pozo_%d" % pozo_malo] == respuesta_mala)
		mision._input(_tecla(KEY_Y))
		assert(mision.modo_panel == &"lectura")
		assert(mision.texto_senas.text.contains("Lectura: clara"))
		mision._input(_tecla(KEY_E))
		_interactuar(mision, jugador, cerro.get_node("HitosCerro/Pozo%d" % pozo_malo))
		mision._input(_tecla(KEY_C))
		assert(not mision.panel_senas.visible)
		assert(mision.agua_recogida == "pozo_%d" % pozo_malo)
		assert(not cerro.get_node("HUD").objetivo_lluvia_completado)
		_interactuar(mision, jugador, cerro.get_node(TIERRAS[LUGARES[indice]]))
		assert(mision.tierra_obtenida)
		_interactuar(mision, jugador, cerro.get_node("HitosCerro/SalidaPueblo"))
		pueblo = juego.escenario_actual
		mision_pueblo = pueblo.get_child(pueblo.get_child_count() - 1)
		assert(mision_pueblo.fase == &"ritual")
		assert(not mision_pueblo.en_casa)
		assert(not mision_pueblo.familia.visible)
		assert(not mision_pueblo.agua_correcta)
		assert(mision_pueblo.tipo_agua == LecturaAgua.tipo_de_pozo("pozo_%d" % pozo_malo, "pozo_%d" % (indice + 1)))
		jugador = pueblo.get_node("Node2D/Jugador") as CharacterBody2D
		jugador.position = Vector2(70, 130)
		mision_pueblo._unhandled_input(_tecla(KEY_E))
		cerro = juego.escenario_actual
		mision = cerro.get_child(cerro.get_child_count() - 1)
		jugador = cerro.get_node("Entidades/Jugador") as CharacterBody2D
		assert(mision.tierra_obtenida)
		assert(mision.pozos_observados.has("pozo_%d" % pozo_malo))
		assert(mision.descriptores_elegidos["pozo_%d" % pozo_malo] == respuesta_mala)
		mision._unhandled_input(_tecla(KEY_B))
		assert(mision.panel_senas.visible)
		mision._input(_tecla(KEY_B))
		assert(not mision.panel_senas.visible)
		mision._unhandled_input(_tecla(KEY_B))
		mision._input(_tecla(KEY_E))
		assert(not mision.panel_senas.visible)
		_interactuar(mision, jugador, cerro.get_node("HitosCerro/Pozo%d" % (indice + 1)))
		mision._input(_tecla(KEY_R))
		var respuesta_buena: Array = LecturaAgua.RESPUESTAS["jallu"]
		for rasgo in range(2):
			mision._input(_tecla(KEY_1 + rasgo))
			for paso in range(respuesta_buena[rasgo]):
				mision._input(_tecla(KEY_RIGHT))
		mision._input(_tecla(KEY_ENTER))
		mision._input(_tecla(KEY_Y))
		assert(mision.texto_senas.text.contains("Lectura: dudosa"))
		mision._input(_tecla(KEY_B))
		mision._input(_tecla(KEY_R))
		for rasgo in range(2, 5):
			mision._input(_tecla(KEY_1 + rasgo))
			for paso in range(respuesta_buena[rasgo]):
				mision._input(_tecla(KEY_RIGHT))
		mision._input(_tecla(KEY_ENTER))
		mision._input(_tecla(KEY_Y))
		assert(mision.texto_senas.text.contains("Lectura: clara"))
		mision._input(_tecla(KEY_E))
		_interactuar(mision, jugador, cerro.get_node("HitosCerro/Pozo%d" % (indice + 1)))
		mision._input(_tecla(KEY_C))
		assert(mision.agua_recogida == "pozo_%d" % (indice + 1))
		_interactuar(mision, jugador, cerro.get_node("HitosCerro/SalidaPueblo"))
		pueblo = juego.escenario_actual
		mision_pueblo = pueblo.get_child(pueblo.get_child_count() - 1)
		assert(mision_pueblo.fase == &"ritual")
		assert(mision_pueblo.tipo_agua == "jallu")
		jugador = pueblo.get_node("Node2D/Jugador") as CharacterBody2D
		jugador.position = Vector2(220, 116)
		mision_pueblo._unhandled_input(_tecla(KEY_E))
		assert(mision_pueblo.fase == &"ritual_en_curso")
		var ritual = mision_pueblo.ritual
		assert(ritual.tipo_agua == "jallu")
		ritual._input(_tecla(KEY_E))
		var patron: Array = ritual.PATRONES[LUGARES[indice]]
		for pieza in range(3):
			ritual._input(_tecla(KEY_1 + pieza))
			for paso in range(patron[pieza]):
				ritual._input(_tecla(KEY_RIGHT))
		ritual._input(_tecla(KEY_ENTER))
		assert(ritual.fase == &"lavar")
		for paso in range(4):
			ritual._input(_tecla(KEY_E))
		assert(mision_pueblo.fase == &"terminada")
		assert(pueblo.get_node("HUD").objetivo_ajayu_completado)
		assert(pueblo.get_node("HUD").objetivo_lluvia_completado)
		assert(pueblo.has_node("ClimaDesenlace"))
		print("OK: indicios y corrección de elección en pozo_%d" % (indice + 1))
		juego.queue_free()
		await process_frame
	for indice_limpieza in range(4):
		await process_frame
	quit()
