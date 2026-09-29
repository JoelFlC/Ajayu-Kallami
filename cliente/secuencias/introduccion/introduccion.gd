extends CanvasLayer

# Adaptación para el juego, no citas del relato. No entrega objetos ni revela el sorteo.
const DIALOGO_ABUELO: Array[Dictionary] = [
	{"voz": "Abuelo", "texto": "Vi una presencia en el camino del Kallami… Después caí. Desde que volví, no logro descansar."},
	{"voz": "Narrador", "texto": "Tu abuelo apenas puede hablar. Te quedas a su lado un momento. Tu abuela te llama: quizá sepa a quién pedir ayuda."}
]
const DIALOGO_ABUELA: Array[Dictionary] = [
	{"voz": "Abuela", "texto": "Dicen que la Ñanqha puede llevarse el ajayu con el susto. Busca al yatiri. Él sabrá cómo llamar el ajayu de tu abuelo."},
	{"voz": "Nieto", "texto": "¿Y si no puedo ayudarlo? Yo no soy yatiri… Y tengo miedo de volver al cerro."},
	{"voz": "Abuela", "texto": "Primero habla con él. Preguntará dónde cayó tu abuelo. Habrá que reunir una prenda suya y tierra de ese lugar."},
	{"voz": "Narrador", "texto": "La comunidad también espera lluvia para la papa. Recuperar el ajayu y bajar el agua de lluvia son dos encargos distintos que te llevan al Kallami."}
]

signal terminada

enum Fase { ABUELO, ABUELA, TERMINADA }

@export var reproducir_al_iniciar: bool = true
@export var ruta_jugador: NodePath = NodePath("../Node2D/Jugador")
@export var ruta_hud: NodePath = NodePath("../HUD")
@export var ruta_abuelo: NodePath = NodePath("../Node2D/FamiliaPrologo/Abuelo")
@export var ruta_abuela: NodePath = NodePath("../Node2D/FamiliaPrologo/Abuela")
@export var distancia_interaccion: float = 34.0
@export var caracteres_por_segundo: float = 42.0

@onready var panel: PanelContainer = $Interfaz/Panel
@onready var voz: Label = $Interfaz/Panel/Margen/Columna/Voz
@onready var contenido: RichTextLabel = $Interfaz/Panel/Margen/Columna/Contenido
@onready var ayuda: Label = $Interfaz/Panel/Margen/Columna/Ayuda
@onready var objetivo: Label = $Interfaz/Objetivo

var fase: Fase = Fase.ABUELO
var activa: bool = false
var indice: int = 0
var _dialogo: Array[Dictionary] = []
var _caracteres: float = 0.0
var _tiempo_lectura: float = 0.0
var _jugador: Node2D
var _hud: Node
var _abuelo: Node2D
var _abuela: Node2D


func _ready() -> void:
	_jugador = get_node_or_null(ruta_jugador) as Node2D
	_hud = get_node_or_null(ruta_hud)
	_abuelo = get_node_or_null(ruta_abuelo) as Node2D
	_abuela = get_node_or_null(ruta_abuela) as Node2D
	panel.hide()
	if reproducir_al_iniciar:
		iniciar()
	else:
		hide()
		set_process(false)
		set_process_unhandled_input(false)


func iniciar() -> void:
	activa = true
	fase = Fase.ABUELO
	_dialogo.clear()
	show()
	set_process(true)
	set_process_unhandled_input(true)
	_mostrar_texto("Narrador", "Tu abuelo regresó enfermo tras una caída en el Kallami. Esta noche decides ayudarlo. Acércate a él: puedes moverte con WASD.")
	_actualizar_objetivo()


func _process(delta: float) -> void:
	_actualizar_objetivo()
	if not panel.visible:
		return
	if contenido.visible_characters < contenido.get_total_character_count():
		_caracteres += delta * maxf(caracteres_por_segundo, 1.0)
		contenido.visible_characters = mini(floori(_caracteres), contenido.get_total_character_count())
	elif _dialogo.is_empty():
		# La narración inicial se retira sola; las conversaciones esperan a E.
		_tiempo_lectura += delta
		if _tiempo_lectura >= 5.0:
			_cerrar_panel()


func _esta_cerca(destino: Node2D) -> bool:
	return is_instance_valid(_jugador) and is_instance_valid(destino) and _jugador.global_position.distance_to(destino.global_position) <= distancia_interaccion


func _actualizar_objetivo() -> void:
	match fase:
		Fase.ABUELO:
			objetivo.text = "E — Hablar con el abuelo" if _esta_cerca(_abuelo) else "Acércate al abuelo · WASD"
		Fase.ABUELA:
			objetivo.text = "E — Hablar con la abuela" if _esta_cerca(_abuela) else "Acércate a la abuela · WASD"
		Fase.TERMINADA:
			objetivo.text = "Siguiente objetivo: buscar al yatiri"


func interactuar() -> void:
	if not activa:
		return
	if not _dialogo.is_empty():
		avanzar()
		return
	if fase == Fase.ABUELO and _esta_cerca(_abuelo):
		_dialogo = DIALOGO_ABUELO.duplicate(true)
	elif fase == Fase.ABUELA and _esta_cerca(_abuela):
		_dialogo = DIALOGO_ABUELA.duplicate(true)
	else:
		# Lejos del interlocutor E solo completa/cierra la narración de entrada.
		if panel.visible:
			avanzar()
		return
	indice = 0
	_mostrar_linea()


func _mostrar_linea() -> void:
	_mostrar_texto(_dialogo[indice]["voz"], _dialogo[indice]["texto"])


func _mostrar_texto(nombre: String, texto: String) -> void:
	voz.text = nombre
	contenido.text = texto
	contenido.visible_characters = 0
	_caracteres = 0.0
	_tiempo_lectura = 0.0
	ayuda.text = "WASD: moverte · E / Enter: continuar · Esc: cerrar"
	panel.show()
	_reservar_panel_hud(true)


func avanzar() -> void:
	if not panel.visible:
		return
	if contenido.visible_characters < contenido.get_total_character_count():
		contenido.visible_characters = contenido.get_total_character_count()
		_caracteres = contenido.get_total_character_count()
		return
	if _dialogo.is_empty():
		_cerrar_panel()
		return
	indice += 1
	if indice < _dialogo.size():
		_mostrar_linea()
	elif fase == Fase.ABUELO:
		_cerrar_panel()
		fase = Fase.ABUELA
		_actualizar_objetivo()
	else:
		finalizar()


func _cerrar_panel() -> void:
	panel.hide()
	_dialogo.clear()
	_reservar_panel_hud(false)


func finalizar() -> void:
	if not activa:
		return
	_cerrar_panel()
	activa = false
	fase = Fase.TERMINADA
	_actualizar_objetivo()
	terminada.emit()


func _reservar_panel_hud(reservado: bool) -> void:
	if is_instance_valid(_hud) and _hud.has_method("reservar_panel_narrativo"):
		_hud.reservar_panel_narrativo(reservado)


func _unhandled_input(evento: InputEvent) -> void:
	if not activa or not evento is InputEventKey or not evento.pressed or evento.echo:
		return
	if evento.keycode == KEY_E:
		interactuar()
		get_viewport().set_input_as_handled()
	elif evento.keycode in [KEY_ENTER, KEY_KP_ENTER] and panel.visible:
		avanzar()
		get_viewport().set_input_as_handled()
	elif evento.keycode == KEY_ESCAPE and panel.visible:
		# Cerrar no completa la misión: se puede volver a hablar con el NPC.
		_cerrar_panel()
		get_viewport().set_input_as_handled()


func _exit_tree() -> void:
	_reservar_panel_hud(false)
