extends CanvasLayer

signal finalizado(ajayu_correcto: bool, lluvia_correcta: bool)
signal cancelado

const PerroEscena = preload("res://cliente/personajes/npc/perro.tscn")
const ClimaScript = preload("res://cliente/efectos/clima/clima_final.gd")
const NUBES: Texture2D = preload("res://cliente/efectos/clima/assets/Clouds.png")

# La miniatura nombra el lugar mediante tres piezas, no mediante una lista
# de topónimos. El interior y las señas específicas aún son provisionales.
const PIEZAS = [
	["Terreno", "hondonada", "ladera rocosa", "paso estrecho"],
	["Piedras", "losas planas", "rocas altas", "cantos de río"],
	["Vegetación", "ichu aislado", "matorrales", "casi ninguna"]
]
const PATRONES = {
	"roqueria_alta": [2, 2, 3],
	"quebrada_media": [1, 3, 2],
	"paso_ladera_alta": [3, 1, 1]
}
const TINTA = Color("f1dfbe")

var lugar_correcto: String = ""
var tierra_correcta: bool = false
var agua_correcta: bool = false
var tipo_agua: String = ""
var fase: StringName = &"prenda"
var piezas: Array[int] = [0, 0, 0]
var pieza_activa: int = 0
var ajayu_correcto: bool = false
var aviso: String = ""

var lienzo: Control
var titulo: Label
var relato: Label
var instrucciones: Label
var menu_piezas: Label
var perro: CharacterBody2D
var escena_clima: Control

var spr_fondo: Sprite2D
var spr_yatiri: Sprite2D
var spr_mesa: Sprite2D
var spr_chompa: Sprite2D
var spr_tierra: Sprite2D
var spr_cantaro: Sprite2D
var spr_vela1: Sprite2D
var spr_vela2: Sprite2D

func _ready() -> void:
	layer = 30
	lienzo = Control.new()
	lienzo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lienzo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lienzo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(lienzo)
	lienzo.draw.connect(_dibujar)
	perro = PerroEscena.instantiate() as CharacterBody2D
	lienzo.add_child(perro)
	perro.position = Vector2(357, 151)
	perro.get_node("AnimatedSprite2D").scale = Vector2.ONE
	escena_clima = Control.new()
	escena_clima.size = Vector2(480, 187)
	escena_clima.clip_contents = true
	escena_clima.mouse_filter = Control.MOUSE_FILTER_IGNORE
	escena_clima.hide()
	lienzo.add_child(escena_clima)
	
	_crear_sprites_objetos()
	
	var caja_dialogo = ColorRect.new()
	caja_dialogo.color = Color("091723")
	caja_dialogo.position = Vector2(8, 187)
	caja_dialogo.size = Vector2(464, 78)
	lienzo.add_child(caja_dialogo)
	
	var borde_dialogo = ReferenceRect.new()
	borde_dialogo.border_color = Color("b58658")
	borde_dialogo.editor_only = false
	borde_dialogo.border_width = 1.0
	borde_dialogo.position = Vector2(8, 187)
	borde_dialogo.size = Vector2(464, 78)
	lienzo.add_child(borde_dialogo)
	
	titulo = _etiqueta(Vector2(16, 6), Vector2(448, 20), 11)
	titulo.add_theme_color_override("font_shadow_color", Color("08131e"))
	titulo.add_theme_constant_override("shadow_offset_x", 1)
	titulo.add_theme_constant_override("shadow_offset_y", 1)
	menu_piezas = _etiqueta(Vector2(24, 48), Vector2(220, 70), 10)
	relato = _etiqueta(Vector2(20, 193), Vector2(440, 42), 10)
	instrucciones = _etiqueta(Vector2(20, 240), Vector2(440, 23), 9)
	_actualizar_vista()


func _etiqueta(posicion: Vector2, tamano: Vector2, fuente: int) -> Label:
	var etiqueta := Label.new()
	etiqueta.position = posicion
	etiqueta.size = tamano
	etiqueta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	etiqueta.add_theme_font_size_override("font_size", fuente)
	etiqueta.add_theme_color_override("font_color", TINTA)
	lienzo.add_child(etiqueta)
	return etiqueta

func _crear_sprites_objetos() -> void:
	var escala = 27.0 / 326.0
	
	spr_fondo = Sprite2D.new()
	spr_fondo.texture = load("res://cliente/sprites/fondos/casaYatiri.png")
	spr_fondo.scale = Vector2(480.0 / 1672.0, 270.0 / 941.0)
	spr_fondo.position = Vector2(240, 135)
	lienzo.add_child(spr_fondo)
	
	spr_yatiri = Sprite2D.new()
	spr_yatiri.texture = load("res://cliente/sprites/npc/yatiri/yatiri.png")
	spr_yatiri.region_enabled = true
	spr_yatiri.region_rect = Rect2(43, 51, 183, 331)
	spr_yatiri.scale = Vector2(escala * 5.0, escala * 5.0)
	spr_yatiri.position = Vector2(160, 145)
	lienzo.add_child(spr_yatiri)
	
	spr_mesa = Sprite2D.new()
	spr_mesa.texture = load("res://cliente/sprites/objetos/mesaPachamama.png")
	spr_mesa.scale = Vector2(0.3, 0.3)
	spr_mesa.position = Vector2(280, 145)
	lienzo.add_child(spr_mesa)
	
	spr_chompa = Sprite2D.new()
	spr_chompa.texture = load("res://cliente/sprites/objetos/chompaAbuelo.png")
	spr_chompa.scale = Vector2(0.12, 0.12)
	spr_chompa.position = Vector2(255, 140)
	lienzo.add_child(spr_chompa)
	
	spr_tierra = Sprite2D.new()
	spr_tierra.texture = load("res://cliente/sprites/objetos/muestraTierra.png")
	spr_tierra.scale = Vector2(0.13, 0.13)
	spr_tierra.position = Vector2(305, 140)
	lienzo.add_child(spr_tierra)
	
	spr_cantaro = Sprite2D.new()
	spr_cantaro.texture = load("res://cliente/sprites/objetos/cantaro.png")
	spr_cantaro.scale = Vector2(0.10, 0.10)
	spr_cantaro.position = Vector2(280, 120)
	lienzo.add_child(spr_cantaro)

	spr_vela1 = Sprite2D.new()
	spr_vela1.texture = load("res://cliente/sprites/objetos/vela.png")
	spr_vela1.scale = Vector2(0.10, 0.10)
	spr_vela1.position = Vector2(240, 150)
	lienzo.add_child(spr_vela1)

	spr_vela2 = Sprite2D.new()
	spr_vela2.texture = load("res://cliente/sprites/objetos/vela.png")
	spr_vela2.scale = Vector2(0.10, 0.10)
	spr_vela2.position = Vector2(320, 150)
	lienzo.add_child(spr_vela2)

func _dibujar() -> void:
	if fase == &"resultado":
		_dibujar_paisaje_resultado()
	else:
		_dibujar_interior()

func _dibujar_interior() -> void:
	pass
	
func _dibujar_paisaje_resultado() -> void:
	# La viñeta muestra el exterior: el clima no cae dentro de la casa.
	var helada := tipo_agua == "juyphi"
	lienzo.draw_rect(Rect2(0, 0, 480, 187), Color("142c3f") if helada else Color("172436"))
	lienzo.draw_rect(Rect2(0, 80, 480, 110), Color("31505b") if helada else Color("3a4a50"))
	lienzo.draw_texture_rect_region(NUBES, Rect2(216, 20, 80, 36), Rect2(0, 0, 80, 36), Color(0.52, 0.63, 0.71, 0.45))
	lienzo.draw_texture_rect_region(NUBES, Rect2(379, 33, 72, 32), Rect2(0, 0, 80, 36), Color(0.52, 0.63, 0.71, 0.35))
	lienzo.draw_colored_polygon(PackedVector2Array([Vector2(0, 127), Vector2(74, 62), Vector2(121, 101), Vector2(205, 42), Vector2(284, 114), Vector2(362, 66), Vector2(480, 124), Vector2(480, 187), Vector2(0, 187)]), Color("6c8290") if helada else Color("525665"))
	lienzo.draw_colored_polygon(PackedVector2Array([Vector2(0, 156), Vector2(107, 113), Vector2(183, 136), Vector2(294, 98), Vector2(388, 142), Vector2(480, 118), Vector2(480, 187), Vector2(0, 187)]), Color("475e68") if helada else Color("394e50"))
	lienzo.draw_rect(Rect2(0, 160, 480, 27), Color("65757b") if helada else Color("5c5545"))
	for x in range(18, 480, 27):
		lienzo.draw_line(Vector2(x, 171), Vector2(x - 4, 159), Color("a9c1bf") if helada else Color("82946b"), 1)
	# Casa del abuelo y pueblo al pie del cerro.
	lienzo.draw_rect(Rect2(35, 123, 88, 46), Color("8a614b"))
	lienzo.draw_colored_polygon(PackedVector2Array([Vector2(25, 126), Vector2(79, 98), Vector2(132, 126)]), Color("513c3c"))
	lienzo.draw_rect(Rect2(77, 142, 20, 27), Color("392b2b"))
	lienzo.draw_rect(Rect2(44, 133, 16, 13), Color("dfba80"))
	lienzo.draw_rect(Rect2(47, 136, 10, 7), Color("526a75"))


func _dibujar_miniatura() -> void:
	lienzo.draw_rect(Rect2(267, 117, 18, 11), Color("73543e"))
	if piezas[0] == 1:
		lienzo.draw_line(Vector2(268, 122), Vector2(284, 122), Color("b49a78"), 2)
	elif piezas[0] == 2:
		lienzo.draw_line(Vector2(268, 126), Vector2(284, 118), Color("b49a78"), 2)
	elif piezas[0] == 3:
		lienzo.draw_rect(Rect2(274, 117, 4, 11), Color("b49a78"))
	for indice in range(piezas[1]):
		lienzo.draw_circle(Vector2(270 + indice * 5, 117), 2, Color("a6a4a0"))
	for indice in range(piezas[2]):
		lienzo.draw_line(Vector2(269 + indice * 5, 117), Vector2(268 + indice * 5, 112), Color("9ca66b"), 1)


func _actualizar_vista() -> void:
	titulo.text = "Cerro Kallami — desenlace" if fase == &"resultado" else "El llamado del ajayu — casa del abuelo"
	if fase == &"resultado" and tipo_agua in ["jallu", "chhijchi", "juyphi"] and not escena_clima.visible:
		var efecto := ClimaScript.new()
		efecto.tipo_agua = tipo_agua
		efecto.area = Vector2(480, 187)
		escena_clima.add_child(efecto)
		escena_clima.show()
	var animacion: StringName = &"sentado" if fase in [&"perro", &"resultado"] else &"idle"
	var sprite_perro := perro.get_node("AnimatedSprite2D") as AnimatedSprite2D
	if sprite_perro.animation != animacion:
		sprite_perro.play(animacion)
	menu_piezas.text = ""
	
	var es_resultado: bool = (fase == &"resultado")
	if is_instance_valid(spr_fondo):
		spr_fondo.visible = not es_resultado
	if is_instance_valid(spr_mesa):
		spr_mesa.visible = not es_resultado
	if is_instance_valid(spr_yatiri):
		spr_yatiri.visible = not es_resultado
		
	if is_instance_valid(spr_chompa):
		spr_chompa.visible = (fase != &"prenda" and not es_resultado)
	if is_instance_valid(spr_tierra):
		spr_tierra.visible = (fase in [&"lavar", &"frotar", &"perro"] and not es_resultado)
	if is_instance_valid(spr_cantaro):
		spr_cantaro.visible = (fase in [&"frotar", &"perro"] and not es_resultado)
	if is_instance_valid(spr_vela1):
		spr_vela1.visible = not es_resultado
	if is_instance_valid(spr_vela2):
		spr_vela2.visible = not es_resultado
		
	match fase:
		&"prenda":
			relato.text = "El yatiri reúne a la familia. Primer acto: coloca una prenda del abuelo sobre la mesa."
			instrucciones.text = "E o Enter: colocar la prenda    Esc: salir"
		&"miniatura":
			var lineas := "ARMA EL LUGAR DE LA CAÍDA\n"
			for indice in range(PIEZAS.size()):
				var valor: int = piezas[indice]
				lineas += "%s%d %s: %s\n" % [">" if indice == pieza_activa else " ", indice + 1, PIEZAS[indice][0], "sin elegir" if valor == 0 else PIEZAS[indice][valor]]
			menu_piezas.text = lineas
			relato.text = aviso if not aviso.is_empty() else "Segundo acto: la miniatura nombra el sitio donde cayó el abuelo. Usa las pistas recogidas."
			instrucciones.text = "1-3: pieza   ←/→: cambiar   Enter: confirmar   Esc: salir"
		&"lavar":
			relato.text = "Tercer acto: vierte el agua del cántaro sobre la tierra del lugar elegido."
			instrucciones.text = "E o Enter: lavar la tierra    Esc: salir"
		&"frotar":
			relato.text = "La tierra ya está húmeda. Aplícala con cuidado sobre el abuelo mientras el yatiri llama a su ajayu."
			instrucciones.text = "E o Enter: frotar la tierra    Esc: salir"
		&"perro":
			relato.text = "El perro permanece quieto durante el cambio ritual. Sigue vivo; el silencio acompaña el llamado."
			instrucciones.text = "E o Enter: escuchar el desenlace"
		&"resultado":
			match tipo_agua:
				"jallu":
					relato.text = "El abuelo respira de nuevo. Llueve sobre la siembra." if ajayu_correcto else "Llueve sobre la siembra, pero el llamado no alcanza al ajayu del abuelo."
				"chhijchi":
					relato.text = "El abuelo se recupera, pero cae granizo: no era jallu uma." if ajayu_correcto else "El llamado no alcanza al ajayu. Afuera cae granizo sobre la siembra."
				"juyphi":
					relato.text = "El abuelo se recupera, pero llega la helada: no era jallu uma." if ajayu_correcto else "El llamado no alcanza al ajayu. La helada cubre la siembra."
				_:
					relato.text = "El abuelo recupera el aliento. Afuera comienza a llover sobre la siembra." if ajayu_correcto and agua_correcta else "El llamado termina, pero falta confirmar el agua traída."
			instrucciones.text = "E o Enter: regresar al pueblo"
	lienzo.queue_redraw()


func _input(evento: InputEvent) -> void:
	if not evento is InputEventKey or not evento.pressed or evento.echo:
		return
	var tecla: Key = evento.keycode
	if tecla == KEY_ESCAPE and fase not in [&"perro", &"resultado"]:
		cancelado.emit()
		queue_free()
	elif fase == &"miniatura":
		if tecla >= KEY_1 and tecla <= KEY_3:
			pieza_activa = tecla - KEY_1
			aviso = ""
			_actualizar_vista()
		elif tecla in [KEY_LEFT, KEY_RIGHT]:
			var paso := -1 if tecla == KEY_LEFT else 1
			var valor_actual: int = piezas[pieza_activa]
			if valor_actual == 0:
				piezas[pieza_activa] = 3 if paso < 0 else 1
			else:
				piezas[pieza_activa] = wrapi(valor_actual - 1 + paso, 0, 3) + 1
			aviso = ""
			_actualizar_vista()
		elif tecla in [KEY_ENTER, KEY_KP_ENTER]:
			if piezas.has(0):
				aviso = "Todavía falta una pieza de la miniatura."
			else:
				fase = &"lavar"
			_actualizar_vista()
	elif tecla in [KEY_E, KEY_ENTER, KEY_KP_ENTER]:
		match fase:
			&"prenda": fase = &"miniatura"
			&"lavar": fase = &"frotar"
			&"frotar": fase = &"perro"
			&"perro":
				ajayu_correcto = tierra_correcta and piezas == PATRONES.get(lugar_correcto, [])
				fase = &"resultado"
			&"resultado":
				finalizado.emit(ajayu_correcto, agua_correcta)
				queue_free()
		_actualizar_vista()
	get_viewport().set_input_as_handled()
