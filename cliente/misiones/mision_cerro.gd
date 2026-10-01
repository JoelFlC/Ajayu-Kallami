extends Node2D

signal volver_al_pueblo(agua_elegida: String, tiene_tierra: bool, observados: Dictionary, notas: Dictionary)

const LecturaAgua = preload("res://cliente/misiones/lectura_agua.gd")
const PerroEscena = preload("res://cliente/personajes/npc/perro.tscn")

const NOMBRES = {
	"roqueria_alta": "roquería alta",
	"quebrada_media": "quebrada media",
	"paso_ladera_alta": "paso alto"
}
const TIERRAS = {
	"roqueria_alta": "HitosCerro/TierraRoqueria",
	"quebrada_media": "HitosCerro/TierraQuebrada",
	"paso_ladera_alta": "HitosCerro/TierraPasoAlto"
}
const TESTIGOS = {
	"pastora": "HitosCerro/UbicacionPastora",
	"comunario": "HitosCerro/UbicacionComunario",
	"niño_pastor": "HitosCerro/UbicacionNinoPastor"
}
const DISTANCIA = 32.0
const AGUAS = {
	"jallu": {
		"color": "verde azulado", "sonido": "un murmullo que corre bajo la piedra",
		"aire": "templado", "vegetacion": "brotes húmedos", "olor": "tierra mojada",
		"tinte": Color("315b61")
	},
	"chhijchi": {
		"color": "gris con motas blancas", "sonido": "golpes secos y espaciados",
		"aire": "frío cortante", "vegetacion": "hierba quebrada", "olor": "piedra húmeda",
		"tinte": Color("65717a")
	},
	"juyphi": {
		"color": "azul pálido e inmóvil", "sonido": "casi ninguno",
		"aire": "helado", "vegetacion": "escarcha sobre tallos quietos", "olor": "apenas perceptible",
		"tinte": Color("7894a3")
	}
}

var partida: Dictionary = {}
var tierra_obtenida: bool = false
var agua_recogida: String = ""
var pozos_observados: Dictionary = {}
var descriptores_elegidos: Dictionary = {}
var pozo_inspeccionado: String = ""
var pozo_bitacora: String = "pozo_1"
var modo_panel: StringName = &"cerrado"
var categoria_activa: int = 0
var seleccion_temporal: Array = []
var jugador: CharacterBody2D
var hud: CanvasLayer
var mapa: Node2D
var panel_senas: CanvasLayer
var texto_senas: Label
var perro: CharacterBody2D


func _ready() -> void:
	mapa = get_parent() as Node2D
	jugador = mapa.get_node("Entidades/Jugador") as CharacterBody2D
	hud = mapa.get_node("HUD") as CanvasLayer
	perro = PerroEscena.instantiate() as CharacterBody2D
	mapa.get_node("Entidades").add_child(perro)
	perro.call("seguir_a", jugador)
	hud.actualizar_ajayu(4)
	hud.actualizar_tiempo(25 * 60)
	_actualizar_inventario()
	_crear_panel_senas()
	for indice in range(1, 4):
		var identificador := "pozo_%d" % indice
		var agua := mapa.get_node("HitosCerro/Pozo%d/Agua" % indice) as Polygon2D
		agua.color = AGUAS[_tipo_pozo(identificador)]["tinte"]
	_aviso("Busca testimonios y tierra. E: examinar pozos; B: bitácora.")
	_crear_sprites_npc()
	_crear_sprites_tierra()
	queue_redraw()

func _crear_sprites_npc() -> void:
	var npcs = {
		"pastora": {
			"ruta": "res://cliente/sprites/npc/pastora/pastora.png",
			"rect": Rect2(21, 27, 174, 286)
		},
		"niño_pastor": {
			"ruta": "res://cliente/sprites/npc/ninoPastor/ninoPastor.png",
			"rect": Rect2(31, 11, 208, 323)
		},
		"comunario": {
			"ruta": "res://cliente/sprites/npc/comunario/comunario.png",
			"rect": Rect2(60, 27, 167, 354)
		}
	}
	var escala = 27.0 / 326.0
	for nombre in npcs:
		var marcador = mapa.get_node(TESTIGOS[nombre])
		var spr = Sprite2D.new()
		spr.texture = load(npcs[nombre]["ruta"])
		spr.region_enabled = true
		spr.region_rect = npcs[nombre]["rect"]
		spr.scale = Vector2(escala, escala)
		spr.position = Vector2(0, -12) # Ajustar la altura visualmente
		marcador.add_child(spr)

func _crear_sprites_tierra() -> void:
	for nombre in TIERRAS:
		var marcador := mapa.get_node(TIERRAS[nombre]) as Node2D
		var spr := Sprite2D.new()
		spr.name = "SpriteTierra"
		spr.texture = load("res://cliente/sprites/objetos/muestraTierra.png")
		spr.scale = Vector2(0.08, 0.08)
		marcador.add_child(spr)

func _draw() -> void:
	for nombre in TESTIGOS:
		var marcador := mapa.get_node(TESTIGOS[nombre]) as Node2D
		var punto := marcador.position
		_texto(punto + Vector2(-24, 17), nombre.replace("_", " "))
	for nombre in TIERRAS:
		var marcador := mapa.get_node(TIERRAS[nombre]) as Node2D
		var ocultar = (tierra_obtenida and nombre == partida.get("lugar_correcto", ""))
		if marcador.has_node("SpriteTierra"):
			marcador.get_node("SpriteTierra").visible = not ocultar
	if not tierra_obtenida or agua_recogida.is_empty():
		return
	var salida := mapa.get_node("HitosCerro/SalidaPueblo") as Node2D
	_texto(salida.position + Vector2(-28, -22), "E: volver al pueblo")


func _texto(posicion: Vector2, contenido: String) -> void:
	draw_string(ThemeDB.fallback_font, posicion + Vector2(1, 1), contenido, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("17212a"))
	draw_string(ThemeDB.fallback_font, posicion, contenido, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("f1dfbe"))


func _aviso(texto: String) -> void:
	if is_instance_valid(hud):
		hud.mostrar_mensaje(texto, 5.0)


func _actualizar_inventario() -> void:
	var objetos: Array = [{"id": "prenda", "nombre": "Prenda"}]
	if tierra_obtenida:
		objetos.append({"id": "tierra", "nombre": "Tierra"})
	if not agua_recogida.is_empty():
		objetos.append({"id": "cantaro", "nombre": "Agua"})
	hud.actualizar_inventario(objetos)


func _tipo_pozo(identificador: String) -> String:
	return LecturaAgua.tipo_de_pozo(identificador, partida["pozo_jallu_uma"])


func _crear_panel_senas() -> void:
	panel_senas = CanvasLayer.new()
	panel_senas.layer = 20
	panel_senas.visible = false
	add_child(panel_senas)
	var sombra := ColorRect.new()
	sombra.color = Color(0.02, 0.05, 0.09, 0.68)
	sombra.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sombra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel_senas.add_child(sombra)
	var caja := PanelContainer.new()
	caja.anchor_left = 0.06
	caja.anchor_top = 0.20
	caja.anchor_right = 0.94
	caja.anchor_bottom = 0.85
	caja.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel_senas.add_child(caja)
	var margen := MarginContainer.new()
	margen.add_theme_constant_override("margin_left", 12)
	margen.add_theme_constant_override("margin_right", 12)
	margen.add_theme_constant_override("margin_top", 9)
	margen.add_theme_constant_override("margin_bottom", 9)
	caja.add_child(margen)
	texto_senas = Label.new()
	texto_senas.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto_senas.add_theme_font_size_override("font_size", 11)
	texto_senas.add_theme_color_override("font_color", Color("f1dfbe"))
	margen.add_child(texto_senas)


func _mostrar_panel(texto: String, tamano: int = 11) -> void:
	texto_senas.text = texto
	texto_senas.add_theme_font_size_override("font_size", tamano)
	hud.ocultar_mensaje()
	panel_senas.show()
	jugador.set_physics_process(false)


func _cerrar_panel() -> void:
	panel_senas.hide()
	modo_panel = &"cerrado"
	pozo_inspeccionado = ""
	jugador.set_physics_process(true)


func _examinar_pozo(identificador: String) -> void:
	var senas: Dictionary = AGUAS[_tipo_pozo(identificador)]
	pozos_observados[identificador] = true
	pozo_inspeccionado = identificador
	modo_panel = &"pozo"
	var numero := identificador.trim_prefix("pozo_")
	_mostrar_panel("POZO %s — SEÑAS OBSERVADAS\nAgua: %s.\nSonido: %s.\nAire: %s. Alrededor: %s.\nOlor: %s.\n\nR: anotar    C: llenar cántaro    B: bitácora    E: cerrar" % [numero, senas["color"], senas["sonido"], senas["aire"], senas["vegetacion"], senas["olor"]], 10)


func _editar_descriptores(identificador: String) -> void:
	if not pozos_observados.has(identificador):
		return
	pozo_inspeccionado = identificador
	seleccion_temporal = descriptores_elegidos.get(identificador, [0, 0, 0, 0, 0]).duplicate()
	categoria_activa = 0
	modo_panel = &"editor"
	_actualizar_editor()


func _actualizar_editor() -> void:
	var lineas := "POZO %s — ANOTAR DESCRIPTORES\n" % pozo_inspeccionado.trim_prefix("pozo_")
	for indice in range(LecturaAgua.CATEGORIAS.size()):
		var valor: int = int(seleccion_temporal[indice])
		var opcion: String = "sin marcar" if valor == 0 else LecturaAgua.OPCIONES[indice][valor - 1]
		lineas += "%s %d %s: %s\n" % [">" if indice == categoria_activa else " ", indice + 1, LecturaAgua.CATEGORIAS[indice], opcion]
	lineas += "\n1-5: elegir rasgo   ←/→: cambiar\nEnter: guardar   E/Esc: cancelar"
	_mostrar_panel(lineas, 10)


func _cantidad_marcados(seleccion: Array) -> int:
	var cantidad := 0
	for valor in seleccion:
		if int(valor) != 0:
			cantidad += 1
	return cantidad


func _mostrar_bitacora() -> void:
	if not pozo_inspeccionado.is_empty():
		pozo_bitacora = pozo_inspeccionado
	pozo_inspeccionado = ""
	modo_panel = &"bitacora"
	var lineas := "BITÁCORA — ELIGE POZO CON 1, 2 O 3\nConsejo: lluvia = brotes y rumor; granizo = golpes; helada = silencio.\n"
	for indice in range(1, 4):
		var identificador := "pozo_%d" % indice
		if pozos_observados.has(identificador):
			var seleccion: Array = descriptores_elegidos.get(identificador, [0, 0, 0, 0, 0])
			lineas += "%s%d: examinado, %d/5 rasgos anotados\n" % [">" if identificador == pozo_bitacora else " ", indice, _cantidad_marcados(seleccion)]
		else:
			lineas += "%s%d: sin examinar\n" % [">" if identificador == pozo_bitacora else " ", indice]
	var notas: Array = descriptores_elegidos.get(pozo_bitacora, [0, 0, 0, 0, 0])
	var resumen := ""
	for indice in range(notas.size()):
		if int(notas[indice]) > 0:
			resumen += "%s: %s; " % [LecturaAgua.CATEGORIAS[indice], LecturaAgua.OPCIONES[indice][int(notas[indice]) - 1]]
	lineas += "\nNotas del pozo %s: %s\nR: editar   Y: consultar al yatiri   B/E: cerrar" % [pozo_bitacora.trim_prefix("pozo_"), resumen if not resumen.is_empty() else "ninguna"]
	_mostrar_panel(lineas, 10)


func _consultar_yatiri() -> void:
	if not pozos_observados.has(pozo_bitacora):
		return
	var seleccion: Array = descriptores_elegidos.get(pozo_bitacora, [0, 0, 0, 0, 0])
	var lectura: Dictionary = LecturaAgua.evaluar(_tipo_pozo(pozo_bitacora), seleccion)
	modo_panel = &"lectura"
	_mostrar_panel("LECTURA DEL YATIRI — POZO %s\n\n%s\n\nLectura: %s\n\nB: volver a la bitácora   E/Esc: cerrar" % [pozo_bitacora.trim_prefix("pozo_"), lectura["texto"], lectura["calidad"]], 10)


func _llenar_cantaro() -> void:
	agua_recogida = pozo_inspeccionado
	_cerrar_panel()
	_actualizar_inventario()
	_aviso("Llenaste el cántaro. El yatiri examinará el agua en el pueblo.")
	queue_redraw()


func _cerca(ruta: String, distancia: float = DISTANCIA) -> bool:
	var punto := mapa.get_node(ruta) as Node2D
	return jugador.global_position.distance_to(punto.global_position) <= distancia


func _input(evento: InputEvent) -> void:
	if not panel_senas.visible or not evento is InputEventKey or not evento.pressed or evento.echo:
		return
	var tecla: Key = evento.keycode
	if tecla in [KEY_E, KEY_ESCAPE]:
		_cerrar_panel()
	elif tecla == KEY_B:
		if modo_panel == &"bitacora":
			_cerrar_panel()
		else:
			_mostrar_bitacora()
	elif modo_panel == &"pozo":
		if tecla == KEY_R:
			_editar_descriptores(pozo_inspeccionado)
		elif tecla == KEY_C:
			_llenar_cantaro()
	elif modo_panel == &"editor":
		if tecla >= KEY_1 and tecla <= KEY_5:
			categoria_activa = tecla - KEY_1
			_actualizar_editor()
		elif tecla in [KEY_LEFT, KEY_RIGHT]:
			var paso := -1 if tecla == KEY_LEFT else 1
			seleccion_temporal[categoria_activa] = wrapi(int(seleccion_temporal[categoria_activa]) + paso, 0, 4)
			_actualizar_editor()
		elif tecla in [KEY_ENTER, KEY_KP_ENTER]:
			descriptores_elegidos[pozo_inspeccionado] = seleccion_temporal.duplicate()
			_mostrar_bitacora()
	elif modo_panel == &"bitacora":
		if tecla >= KEY_1 and tecla <= KEY_3:
			pozo_bitacora = "pozo_%d" % (tecla - KEY_1 + 1)
			_mostrar_bitacora()
		elif tecla == KEY_R:
			_editar_descriptores(pozo_bitacora)
		elif tecla == KEY_Y:
			_consultar_yatiri()
	get_viewport().set_input_as_handled()


func _unhandled_input(evento: InputEvent) -> void:
	if not evento is InputEventKey or not evento.pressed or evento.echo:
		return
	if panel_senas.visible:
		return
	if evento.keycode == KEY_B:
		_mostrar_bitacora()
		get_viewport().set_input_as_handled()
		return
	if evento.keycode != KEY_E:
		return
	for nombre in TESTIGOS:
		if _cerca(TESTIGOS[nombre]):
			var testimonio: Dictionary = partida["testimonios"][nombre]
			_aviso(nombre.replace("_", " ") + ": " + NOMBRES[testimonio["candidato_mencionado"]])
			get_viewport().set_input_as_handled()
			return
	for nombre in TIERRAS:
		if _cerca(TIERRAS[nombre]):
			if tierra_obtenida:
				_aviso("Ya llevas tierra del lugar.")
			elif nombre == partida["lugar_correcto"]:
				tierra_obtenida = true
				_actualizar_inventario()
				_aviso("Recogiste la tierra correcta.")
				queue_redraw()
			else:
				_aviso("Tu abuelo no cayó aquí.")
			get_viewport().set_input_as_handled()
			return
	for indice in range(1, 4):
		if _cerca("HitosCerro/Pozo%d" % indice, 42.0):
			_examinar_pozo("pozo_%d" % indice)
			get_viewport().set_input_as_handled()
			return
	if _cerca("HitosCerro/SalidaPueblo", 40.0):
		get_viewport().set_input_as_handled()
		if tierra_obtenida and not agua_recogida.is_empty():
			volver_al_pueblo.emit(agua_recogida, tierra_obtenida, pozos_observados.duplicate(), descriptores_elegidos.duplicate(true))
		else:
			_aviso("Faltan tierra del lugar y agua en el cántaro.")
