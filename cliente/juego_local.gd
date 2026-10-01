extends Node

const CERRO = preload("res://cliente/niveles/cerro/cerro_prologo.tscn")
const CERRO_MISION = preload("res://cliente/niveles/cerro/cerro_clip2.tscn")
const PUEBLO = preload("res://cliente/niveles/pueblo/pueblo.tscn")
const SorteoScript = preload("res://servidor/sorteo.gd")
const MisionPuebloScript = preload("res://cliente/misiones/mision_pueblo.gd")
const MisionCerroScript = preload("res://cliente/misiones/mision_cerro.gd")
const LecturaAgua = preload("res://cliente/misiones/lectura_agua.gd")

const LUGARES_SUSTO = {
	"roqueria_alta": Vector2(245, -530),
	"quebrada_media": Vector2(770, -535),
	"paso_ladera_alta": Vector2(520, -990)
}
const NOMBRES_SUSTO = {
	"roqueria_alta": "la roquería alta",
	"quebrada_media": "la quebrada media",
	"paso_ladera_alta": "el paso de la ladera alta"
}

var escenario_actual: Node
var cambiando_de_escena: bool = false
var partida: Dictionary = {}
var tierra_obtenida: bool = false
var agua_elegida: String = ""
var pozos_observados: Dictionary = {}
var descriptores_elegidos: Dictionary = {}
var en_prologo: bool = true


func _ready() -> void:
	# El sorteo existente se usa solo para esta partida de un jugador.
	var sorteo := SorteoScript.new()
	partida = sorteo.sortear_partida()
	sorteo.free()
	var cerro := CERRO.instantiate()
	cerro.get_node("ZonaSusto").position = LUGARES_SUSTO[partida["lugar_correcto"]]
	cerro.nombre_lugar_susto = NOMBRES_SUSTO[partida["lugar_correcto"]]
	cerro.permitir_omitir = true
	escenario_actual = cerro
	add_child(cerro)
	cerro.ajayu_perdido.connect(_al_perder_ajayu)


func _unhandled_key_input(evento: InputEvent) -> void:
	if not en_prologo or cambiando_de_escena or not evento is InputEventKey:
		return
	if not evento.pressed or evento.echo:
		return
	if evento.keycode != KEY_ENTER and evento.keycode != KEY_KP_ENTER \
			and evento.physical_keycode != KEY_ENTER and evento.physical_keycode != KEY_KP_ENTER:
		return
	# Atajo opcional solo antes del susto: la escena normal sigue funcionando.
	if escenario_actual.prologo_terminado or escenario_actual.evento.estado != &"listo":
		return
	get_viewport().set_input_as_handled()
	_mostrar_pueblo(false)


func _al_perder_ajayu() -> void:
	if cambiando_de_escena:
		return
	cambiando_de_escena = true
	var cerro := escenario_actual
	await get_tree().create_timer(2.5).timeout
	if not is_instance_valid(cerro) or not cerro.prologo_terminado:
		cambiando_de_escena = false
		return
	_mostrar_pueblo(false)


func _reemplazar(nuevo: Node) -> void:
	if is_instance_valid(escenario_actual):
		remove_child(escenario_actual)
		escenario_actual.queue_free()
	escenario_actual = nuevo
	add_child(nuevo)


func _mostrar_pueblo(regreso_con_tierra: bool) -> void:
	en_prologo = false
	var pueblo := PUEBLO.instantiate()
	pueblo.get_node("HUD").modo_demostracion = false
	pueblo.get_node("Introduccion").reproducir_al_iniciar = not regreso_con_tierra
	if regreso_con_tierra:
		pueblo.get_node("Node2D/Jugador").position = Vector2(382, 211)
		pueblo.get_node("Node2D/CasaAbuelo").hide()
		pueblo.get_node("Node2D/FamiliaPrologo").hide()
	_reemplazar(pueblo)
	var mision := MisionPuebloScript.new()
	mision.regreso_con_tierra = regreso_con_tierra
	mision.agua_correcta = agua_elegida == partida["pozo_jallu_uma"]
	mision.tipo_agua = LecturaAgua.tipo_de_pozo(agua_elegida, partida["pozo_jallu_uma"])
	mision.tierra_correcta = tierra_obtenida
	mision.lugar_correcto = partida["lugar_correcto"]
	pueblo.add_child(mision)
	mision.partir_al_cerro.connect(_mostrar_cerro_mision)
	mision.ritual_completado.connect(_al_completar_ritual)
	cambiando_de_escena = false


func _mostrar_cerro_mision() -> void:
	var cerro := CERRO_MISION.instantiate()
	cerro.get_node("Entidades/Jugador").position = Vector2(496, -48)
	cerro.get_node("HUD").modo_demostracion = false
	# La bitácora ficticia de esta escena de prueba no forma parte de la misión.
	cerro.get_node("FakeUI").free()
	_reemplazar(cerro)
	var mision := MisionCerroScript.new()
	mision.partida = partida.duplicate(true)
	mision.tierra_obtenida = tierra_obtenida
	mision.pozos_observados = pozos_observados.duplicate()
	mision.descriptores_elegidos = descriptores_elegidos.duplicate(true)
	cerro.add_child(mision)
	mision.volver_al_pueblo.connect(_al_volver_del_cerro)


func _al_volver_del_cerro(agua_seleccionada: String, tiene_tierra: bool, observados: Dictionary, notas: Dictionary) -> void:
	agua_elegida = agua_seleccionada
	tierra_obtenida = tiene_tierra
	pozos_observados = observados.duplicate()
	descriptores_elegidos = notas.duplicate(true)
	_mostrar_pueblo(true)


func _al_completar_ritual(ajayu_correcto: bool, lluvia_correcta: bool) -> void:
	print("Prueba local completa. Ajayu: ", ajayu_correcto, "; lluvia: ", lluvia_correcta)
