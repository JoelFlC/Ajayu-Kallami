extends Node2D

signal partir_al_cerro
signal ritual_completado(ajayu_correcto: bool, lluvia_correcta: bool)

const RitualFinalScript = preload("res://cliente/rituales/ritual_final.gd")
const ClimaScript = preload("res://cliente/efectos/clima/clima_final.gd")
const PerroEscena = preload("res://cliente/personajes/npc/perro.tscn")

const YATIRI_POS = Vector2(220, 116)
const SALIDA_POS = Vector2(70, 130)
const DISTANCIA = 32.0
const VELOCIDAD_CASA = 80.0
const VELOCIDAD_EXTERIOR = 150.0

var regreso_con_tierra: bool = false
var agua_correcta: bool = false
var tipo_agua: String = ""
var tierra_correcta: bool = false
var lugar_correcto: String = ""
var fase: StringName = &"introduccion"
var jugador: CharacterBody2D
var introduccion: CanvasLayer
var hud: CanvasLayer
var abuelo: Node2D
var familia: Node2D
var casa: Node2D
var puerta_exterior: Marker2D
var puerta_interior: Marker2D
var en_casa: bool = true
var ritual: CanvasLayer
var perro: CharacterBody2D


func _ready() -> void:
	var pueblo := get_parent()
	jugador = pueblo.get_node("Node2D/Jugador") as CharacterBody2D
	introduccion = pueblo.get_node("Introduccion") as CanvasLayer
	hud = pueblo.get_node("HUD") as CanvasLayer
	abuelo = pueblo.get_node("Node2D/FamiliaPrologo/Abuelo") as Node2D
	familia = pueblo.get_node("Node2D/FamiliaPrologo") as Node2D
	casa = pueblo.get_node("Node2D/CasaAbuelo") as Node2D
	puerta_exterior = pueblo.get_node("Node2D/PuertaExterior") as Marker2D
	puerta_interior = pueblo.get_node("Node2D/CasaAbuelo/PuertaInterior") as Marker2D
	en_casa = casa.visible
	_actualizar_velocidad_jugador()
	perro = PerroEscena.instantiate() as CharacterBody2D
	pueblo.get_node("Node2D").add_child(perro)
	perro.call("seguir_a", jugador)
	introduccion.terminada.connect(_al_terminar_introduccion)
	hud.actualizar_ajayu(4)
	hud.actualizar_tiempo(25 * 60)
	hud.actualizar_inventario([{"id": "prenda", "nombre": "Prenda"}, {"id": "tierra", "nombre": "Tierra"}, {"id": "cantaro", "nombre": "Agua"}] if regreso_con_tierra else [])
	if regreso_con_tierra:
		introduccion.hide()
		fase = &"ritual"
		_aviso("Lleva prenda, tierra y cántaro al yatiri para iniciar el llamado.")
	elif not introduccion.activa:
		_al_terminar_introduccion()
		
	_crear_sprite_yatiri()
	queue_redraw()

func _crear_sprite_yatiri() -> void:
	var spr = Sprite2D.new()
	spr.texture = load("res://cliente/sprites/npc/yatiri/yatiri.png")
	spr.region_enabled = true
	spr.region_rect = Rect2(43, 51, 183, 331)
	var escala = 27.0 / 326.0
	spr.scale = Vector2(escala, escala)
	# YATIRI_POS es Vector2(220, 116), lo ponemos en la posicion
	spr.position = YATIRI_POS + Vector2(0, -15)
	add_child(spr)

func _draw() -> void:
	_texto(YATIRI_POS + Vector2(-15, 9), "Yatiri", 9)
	if fase == &"ritual":
		_texto(YATIRI_POS + Vector2(-36, -32), "E: entrar a la casa", 8)
	_texto(SALIDA_POS + Vector2(-31, 0), "Camino al cerro", 8)
	if fase not in [&"introduccion", &"terminada"]:
		_texto(SALIDA_POS + Vector2(-7, 12), "E", 9)


func _texto(posicion: Vector2, contenido: String, tamano: int) -> void:
	draw_string(ThemeDB.fallback_font, posicion + Vector2(1, 1), contenido, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano, Color("17212a"))
	draw_string(ThemeDB.fallback_font, posicion, contenido, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano, Color("f1dfbe"))


func _al_terminar_introduccion() -> void:
	if regreso_con_tierra:
		return
	introduccion.hide()
	fase = &"yatiri"
	_aviso("Sal de casa con E junto a la puerta y busca al yatiri en el pueblo.")
	queue_redraw()


func _entrar_casa() -> void:
	en_casa = true
	_actualizar_velocidad_jugador()
	casa.show()
	familia.show()
	jugador.global_position = puerta_interior.global_position + Vector2(0, -14)
	casa.get_node("Camera2D").make_current()
	perro.call("seguir_a", jugador)
	_aviso("Estás en casa de tu abuelo. E junto a la puerta para salir.")
	queue_redraw()


func _salir_casa() -> void:
	en_casa = false
	_actualizar_velocidad_jugador()
	jugador.global_position = puerta_exterior.global_position + Vector2(0, 18)
	casa.hide()
	familia.hide()
	jugador.get_node("Camera2D").make_current()
	perro.call("seguir_a", jugador)
	_aviso("Saliste de la casa. E junto a la puerta para volver a entrar.")
	queue_redraw()


func _actualizar_velocidad_jugador() -> void:
	jugador.set("velocidad_movimiento", VELOCIDAD_CASA if en_casa else VELOCIDAD_EXTERIOR)


func _cerca(posicion: Vector2) -> bool:
	return is_instance_valid(jugador) and jugador.position.distance_to(posicion) <= DISTANCIA


func _aviso(texto: String) -> void:
	if is_instance_valid(hud):
		hud.mostrar_mensaje(texto, 5.0)


func _iniciar_ritual() -> void:
	fase = &"ritual_en_curso"
	ritual = RitualFinalScript.new()
	ritual.lugar_correcto = lugar_correcto
	ritual.tierra_correcta = tierra_correcta
	ritual.agua_correcta = agua_correcta
	ritual.tipo_agua = tipo_agua
	add_child(ritual)
	ritual.finalizado.connect(_al_terminar_ritual)
	ritual.cancelado.connect(_al_cancelar_ritual)
	hud.hide()
	jugador.set_physics_process(false)
	queue_redraw()


func _al_terminar_ritual(ajayu_bien: bool, lluvia_bien: bool) -> void:
	fase = &"terminada"
	hud.show()
	hud.actualizar_objetivo_ajayu(ajayu_bien)
	hud.actualizar_objetivo_lluvia(lluvia_bien)
	jugador.set_physics_process(true)
	perro.call("quedarse_sentado", jugador.global_position + Vector2(-20, 8))
	_mostrar_clima_exterior()
	_aviso("Terminó el llamado. Los dos encargos se evalúan por separado.")
	ritual_completado.emit(ajayu_bien, lluvia_bien)
	queue_redraw()


func _mostrar_clima_exterior() -> void:
	if not tipo_agua in ["jallu", "chhijchi", "juyphi"]:
		return
	if get_parent().has_node("ClimaDesenlace"):
		return
	var capa := CanvasLayer.new()
	capa.name = "ClimaDesenlace"
	capa.layer = 5 # Sobre el mundo y bajo el HUD.
	get_parent().add_child(capa)
	var recorte := Control.new()
	recorte.mouse_filter = Control.MOUSE_FILTER_IGNORE
	recorte.clip_contents = true
	capa.add_child(recorte)
	recorte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var efecto := ClimaScript.new()
	efecto.tipo_agua = tipo_agua
	efecto.area = get_viewport_rect().size
	recorte.add_child(efecto)


func _al_cancelar_ritual() -> void:
	fase = &"ritual"
	hud.show()
	jugador.set_physics_process(true)
	_aviso("Puedes volver al cerro o iniciar el ritual cuando estés listo.")
	queue_redraw()


func _unhandled_input(evento: InputEvent) -> void:
	if not evento is InputEventKey or not evento.pressed or evento.echo or evento.keycode != KEY_E:
		return
	if introduccion.activa or fase in [&"introduccion", &"ritual_en_curso", &"terminada"]:
		return
	if en_casa:
		if jugador.global_position.distance_to(puerta_interior.global_position) <= DISTANCIA:
			_salir_casa()
			get_viewport().set_input_as_handled()
		elif fase == &"prenda" and jugador.global_position.distance_to(abuelo.global_position) <= DISTANCIA:
			fase = &"salida"
			hud.actualizar_inventario([{"id": "prenda", "nombre": "Prenda"}])
			_aviso("Guardaste la prenda. Ve al cerro.")
			queue_redraw()
			get_viewport().set_input_as_handled()
		return
	if jugador.global_position.distance_to(puerta_exterior.global_position) <= DISTANCIA:
		_entrar_casa()
		get_viewport().set_input_as_handled()
		return
	if _cerca(YATIRI_POS):
		if fase == &"yatiri":
			fase = &"prenda"
			_aviso("Yatiri: trae una prenda. Lluvia: brotes y murmullo; granizo golpea, helada calla.")
		elif fase == &"ritual":
			_iniciar_ritual()
		queue_redraw()
		get_viewport().set_input_as_handled()
	elif _cerca(SALIDA_POS):
		get_viewport().set_input_as_handled()
		if fase in [&"salida", &"ritual"]:
			fase = &"viajando"
			partir_al_cerro.emit()
		else:
			_aviso("Habla antes con el yatiri.")
