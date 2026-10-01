extends CanvasLayer

# Regiones de la imagen original. El PNG se conserva tal como fue entregado.
const ARTE_HUD: Texture2D = preload("res://cliente/sprites/ui/hud_andino.png")
const REGION_AJAYU = Rect2(18, 14, 365, 150)
const REGION_RELOJ = Rect2(682, 8, 321, 118)
const REGION_OBJETIVOS = Rect2(1288, 15, 370, 198)
const REGION_INVENTARIO = Rect2(420, 728, 836, 177)
const REGION_VELA = Rect2(15, 735, 286, 162)
const REGION_MENSAJE = Rect2(695, 651, 286, 75)
const REGION_PRENDA = Rect2(505, 778, 76, 64)
const REGION_TIERRA = Rect2(621, 782, 78, 59)

const FONDO = Color("07131f")
const TEXTO = Color("f1dfbe")
const BORDE = Color("445365")
const DORADO = Color("efb44f")
const APAGADO = Color("34404d")
const ROJO = Color("e65433")
const MAX_AJAYU = 4
const ESPACIOS = 6

signal espacio_seleccionado(indice: int)

@export var modo_demostracion: bool = true

@onready var interfaz: Control = $Interfaz
@onready var temporizador_mensaje: Timer = $TemporizadorMensaje

var ajayu: int = MAX_AJAYU
var segundos_restantes: int = 25 * 60
var objetivo_ajayu_completado: bool = false
var objetivo_lluvia_completado: bool = false
var objetos: Array = []
var indice_seleccionado: int = 0
var vela_encendida: bool = true
var mensaje: String = ""
var panel_narrativo_visible: bool = false


func _ready() -> void:
	interfaz.draw.connect(_dibujar_hud)
	interfaz.resized.connect(interfaz.queue_redraw)
	temporizador_mensaje.timeout.connect(ocultar_mensaje)
	if modo_demostracion:
		actualizar_ajayu(3)
		actualizar_tiempo(23 * 60 + 45)
		actualizar_inventario([
			{"id": "prenda", "nombre": "Prenda"},
			{"id": "tierra", "nombre": "Tierra"},
			{"id": "mesa", "nombre": "Ofrenda"}
		])
		mostrar_mensaje("HUD de prueba", 3.0)
	interfaz.queue_redraw()


func actualizar_ajayu(valor: int) -> void:
	ajayu = clampi(valor, 0, MAX_AJAYU)
	_redibujar()


func actualizar_tiempo(segundos: int) -> void:
	# Solo muestra el tiempo recibido; el reloj de partida corresponde al servidor.
	segundos_restantes = maxi(segundos, 0)
	_redibujar()


func actualizar_objetivo_ajayu(completado: bool) -> void:
	objetivo_ajayu_completado = completado
	_redibujar()


func actualizar_objetivo_lluvia(completado: bool) -> void:
	objetivo_lluvia_completado = completado
	_redibujar()


func actualizar_inventario(nuevos_objetos: Array) -> void:
	objetos = nuevos_objetos.slice(0, ESPACIOS).duplicate(true)
	_redibujar()


func seleccionar_espacio(indice: int) -> void:
	if indice < 0 or indice >= ESPACIOS:
		return
	indice_seleccionado = indice
	_redibujar()
	espacio_seleccionado.emit(indice)


func actualizar_vela(encendida: bool) -> void:
	vela_encendida = encendida
	_redibujar()


func mostrar_mensaje(texto: String, duracion: float = 2.0) -> void:
	mensaje = texto
	if is_node_ready():
		temporizador_mensaje.stop()
		if not texto.is_empty() and duracion > 0.0:
			temporizador_mensaje.start(duracion)
	_redibujar()


func ocultar_mensaje() -> void:
	mensaje = ""
	if is_node_ready():
		temporizador_mensaje.stop()
	_redibujar()


func _redibujar() -> void:
	if is_node_ready():
		interfaz.queue_redraw()


func reservar_panel_narrativo(reservado: bool) -> void:
	# Conserva los datos y los indicadores superiores; libera solo la zona inferior.
	panel_narrativo_visible = reservado
	_redibujar()


func _escala_interfaz() -> float:
	return maxf(0.01, minf(1.0, minf(interfaz.size.x / 480.0, interfaz.size.y / 270.0)))


func _rect_inventario() -> Rect2:
	var tamano := interfaz.size / _escala_interfaz()
	return Rect2(Vector2(roundf((tamano.x - 232.0) / 2.0), tamano.y - 53.0), Vector2(232, 49))


func _rect_espacio(indice: int) -> Rect2:
	return Rect2(_rect_inventario().position + Vector2(20 + indice * 33, 9), Vector2(28, 27))


func _unhandled_input(evento: InputEvent) -> void:
	if panel_narrativo_visible:
		return
	if evento is InputEventKey and evento.pressed and not evento.echo:
		if evento.keycode >= KEY_1 and evento.keycode <= KEY_6:
			seleccionar_espacio(evento.keycode - KEY_1)
			get_viewport().set_input_as_handled()
	elif evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT and evento.pressed:
		var posicion := interfaz.get_local_mouse_position() / _escala_interfaz()
		for indice in range(ESPACIOS):
			if _rect_espacio(indice).has_point(posicion):
				seleccionar_espacio(indice)
				get_viewport().set_input_as_handled()
				break


func _dibujar_hud() -> void:
	var escala := _escala_interfaz()
	var tamano := interfaz.size / escala
	interfaz.draw_set_transform(Vector2.ZERO, 0.0, Vector2(escala, escala))
	_dibujar_ajayu(Vector2(6, 5))
	_dibujar_reloj(Vector2(roundf((tamano.x - 90.0) / 2.0), 5))
	_dibujar_objetivos(Vector2(tamano.x - 110.0, 5))
	if not panel_narrativo_visible:
		_dibujar_inventario()
		_dibujar_vela(Vector2(6, tamano.y - 49.0))
	if not panel_narrativo_visible and not mensaje.is_empty():
		var ancho := clampf(ThemeDB.fallback_font.get_string_size(mensaje, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x + 18, 84, tamano.x - 24)
		var posicion := Vector2(roundf((tamano.x - ancho) / 2.0), tamano.y - 77.0)
		_imagen(Rect2(posicion, Vector2(ancho, 22)), REGION_MENSAJE)
		interfaz.draw_rect(Rect2(posicion + Vector2(8, 4), Vector2(ancho - 16, 14)), FONDO)
		_texto(mensaje, posicion + Vector2(9, 15), 10, TEXTO, ancho - 18)
	interfaz.draw_set_transform(Vector2.ZERO)


func _imagen(destino: Rect2, region: Rect2, color: Color = Color.WHITE) -> void:
	interfaz.draw_texture_rect_region(ARTE_HUD, destino, region, color)


func _texto(texto: String, posicion: Vector2, tamano: int = 10, color: Color = TEXTO, ancho: float = -1.0) -> void:
	var fuente := ThemeDB.fallback_font
	var contenido := texto
	if ancho > 0:
		while fuente.get_string_size(contenido, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano).x > ancho and contenido.length() > 1:
			contenido = contenido.left(contenido.length() - 1)
	interfaz.draw_string(fuente, posicion, contenido, HORIZONTAL_ALIGNMENT_LEFT, -1, tamano, color)


func _dibujar_ajayu(posicion: Vector2) -> void:
	_imagen(Rect2(posicion, Vector2(104, 43)), REGION_AJAYU)
	interfaz.draw_rect(Rect2(posicion + Vector2(37, 6), Vector2(52, 27)), FONDO)
	_texto("Ajayu", posicion + Vector2(39, 17), 12)
	for indice in range(MAX_AJAYU):
		var punto := posicion + Vector2(39 + indice * 12, 24)
		interfaz.draw_rect(Rect2(punto, Vector2(8, 8)), ROJO if indice < ajayu else APAGADO, false, 1.0)
		interfaz.draw_rect(Rect2(punto + Vector2(2, 2), Vector2(4, 4)), DORADO if indice < ajayu else BORDE)


func _dibujar_reloj(posicion: Vector2) -> void:
	_imagen(Rect2(posicion, Vector2(90, 33)), REGION_RELOJ)
	interfaz.draw_rect(Rect2(posicion + Vector2(40, 7), Vector2(37, 18)), FONDO)
	var minutos := floori(segundos_restantes / 60.0)
	var texto := "%02d:%02d" % [minutos, segundos_restantes % 60]
	_texto(texto, posicion + Vector2(41, 22), 13, ROJO if segundos_restantes < 300 else TEXTO, 36)
	if modo_demostracion:
		_texto("PRUEBA", posicion + Vector2(31, 43), 8, DORADO)


func _dibujar_objetivos(posicion: Vector2) -> void:
	_imagen(Rect2(posicion, Vector2(104, 55)), REGION_OBJETIVOS)
	interfaz.draw_rect(Rect2(posicion + Vector2(22, 6), Vector2(68, 43)), FONDO)
	_texto("Objetivos", posicion + Vector2(23, 17), 11)
	_dibujar_objetivo(posicion + Vector2(23, 26), "Llamar al ajayu", objetivo_ajayu_completado)
	_dibujar_objetivo(posicion + Vector2(23, 39), "Bajar jallu uma", objetivo_lluvia_completado)


func _dibujar_objetivo(posicion: Vector2, texto: String, completado: bool) -> void:
	interfaz.draw_rect(Rect2(posicion, Vector2(5, 5)), DORADO if completado else BORDE, false, 1.0)
	if completado:
		interfaz.draw_line(posicion + Vector2(1, 2), posicion + Vector2(2, 4), DORADO)
		interfaz.draw_line(posicion + Vector2(2, 4), posicion + Vector2(5, 0), DORADO)
	_texto(texto, posicion + Vector2(8, 6), 8, TEXTO, 64)


func _dibujar_inventario() -> void:
	var rectangulo := _rect_inventario()
	_imagen(rectangulo, REGION_INVENTARIO)
	interfaz.draw_rect(Rect2(rectangulo.position + Vector2(18, 1), Vector2(194, 7)), FONDO)
	interfaz.draw_rect(Rect2(rectangulo.position + Vector2(18, 37), Vector2(194, 9)), FONDO)
	for indice in range(ESPACIOS):
		var espacio := _rect_espacio(indice)
		interfaz.draw_rect(espacio.grow(2), FONDO)
		interfaz.draw_rect(espacio, DORADO if indice == indice_seleccionado else BORDE, false, 1.0)
		_texto(str(indice + 1), espacio.position + Vector2(11, -2), 8)
		if indice >= objetos.size():
			continue
		var objeto = objetos[indice]
		var nombre := str(objeto.get("nombre", "Objeto")) if objeto is Dictionary else str(objeto)
		var identificador := str(objeto.get("id", "")) if objeto is Dictionary else nombre.to_lower()
		if objeto is Dictionary and objeto.get("icono") is Texture2D:
			interfaz.draw_texture_rect(objeto["icono"], Rect2(espacio.position + Vector2(3, 3), Vector2(22, 21)), false)
		elif identificador == "prenda":
			_imagen(Rect2(espacio.position + Vector2(3, 4), Vector2(22, 19)), REGION_PRENDA)
		elif identificador.begins_with("tierra"):
			_imagen(Rect2(espacio.position + Vector2(3, 5), Vector2(22, 17)), REGION_TIERRA)
		elif identificador == "cantaro":
			interfaz.draw_texture_rect_region(preload("res://cliente/sprites/objetos/cantaro.png"), Rect2(espacio.position + Vector2(3, 3), Vector2(22, 21)), Rect2(36, 1, 302, 358))
		else:
			# Marcador provisional de ofrenda; no representa una mesa de madera.
			var centro := espacio.get_center()
			interfaz.draw_colored_polygon(PackedVector2Array([centro + Vector2(0, -8), centro + Vector2(9, 0), centro + Vector2(0, 8), centro + Vector2(-9, 0)]), Color("98423d"))
			interfaz.draw_rect(Rect2(centro - Vector2(2, 2), Vector2(4, 4)), DORADO)
		_texto(nombre, espacio.position + Vector2(-1, 35), 8, TEXTO, 32)


func _dibujar_vela(posicion: Vector2) -> void:
	# Al apagar, se oscurece también la llama dibujada en el arte original.
	_imagen(Rect2(posicion, Vector2(78, 44)), REGION_VELA, Color.WHITE if vela_encendida else Color(0.3, 0.3, 0.3))
	interfaz.draw_rect(Rect2(posicion + Vector2(36, 25), Vector2(27, 11)), FONDO)
	_texto("ON" if vela_encendida else "OFF", posicion + Vector2(41, 34), 9, DORADO if vela_encendida else BORDE)
