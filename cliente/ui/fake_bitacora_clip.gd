extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var etiqueta_aviso: Label = $AvisoInteraccion

# Distancia a la que el jugador puede interactuar con los pozos
var distancia_interaccion: float = 60.0
var pozos: Array[Node] = []
var jugador: CharacterBody2D

func _ready() -> void:
	panel.hide()
	etiqueta_aviso.hide()
	
	_aplicar_estetica_hud()
	
	# Buscamos al jugador y a los pozos dinámicamente
	jugador = get_parent().get_node_or_null("Entidades/Jugador")
	if not jugador:
		# Si no está en Entidades, buscar en todo el árbol (ignora owner)
		var jugadores = get_tree().current_scene.find_children("Jugador", "", true, false)
		if jugadores.size() > 0:
			jugador = jugadores[0]
			
	# Buscamos todos los pozos en la escena ignorando owner para buscar dentro de HitosCerro
	pozos = get_tree().current_scene.find_children("*Pozo*", "", true, false)


func _process(_delta: float) -> void:
	if not jugador or pozos.is_empty():
		return
		
	var pozo_cercano: Node2D = null
	for pozo in pozos:
		if jugador.global_position.distance_to(pozo.global_position) < distancia_interaccion:
			pozo_cercano = pozo
			break
			
	if pozo_cercano:
		if not panel.visible:
			etiqueta_aviso.show()
			etiqueta_aviso.text = ""
			
		if Input.is_action_just_pressed("interactuar"):
			etiqueta_aviso.hide()
			panel.visible = not panel.visible # Alternar visibilidad
	else:
		etiqueta_aviso.hide()
		panel.hide()

func _aplicar_estetica_hud() -> void:
	# Colores del HUD
	var fondo_color = Color("07131f")
	var texto_color = Color("f1dfbe")
	
	# Textura original
	var arte_hud = preload("res://cliente/sprites/ui/hud_andino.png")
	
	# 1. Estilizar el Panel (Fondo de Bitácora)
	var estilo_panel = StyleBoxTexture.new()
	estilo_panel.texture = arte_hud
	# Region de los objetivos que tiene bordes andinos
	estilo_panel.region_rect = Rect2(1288, 15, 370, 198) 
	estilo_panel.texture_margin_left = 60
	estilo_panel.texture_margin_right = 60
	estilo_panel.texture_margin_top = 20
	estilo_panel.texture_margin_bottom = 20
	estilo_panel.draw_center = false # Oculta el texto incrustado en la imagen original
	
	panel.add_theme_stylebox_override("panel", estilo_panel)
	
	# Reducir el tamaño del panel ya que el juego es de 480x270
	panel.custom_minimum_size = Vector2(240, 160)
	panel.size = Vector2(240, 160)
	panel.offset_left = -120
	panel.offset_top = -80
	panel.offset_right = 120
	panel.offset_bottom = 80
	
	# Rehabilitar el ColorRect para que actúe como fondo (tapando el hueco del draw_center)
	var color_rect = panel.get_node_or_null("ColorRect")
	if color_rect:
		color_rect.show()
		color_rect.color = fondo_color
		# Separar un poco de los bordes andinos
		color_rect.layout_mode = 1 # Anchors
		color_rect.anchor_left = 0.0
		color_rect.anchor_top = 0.0
		color_rect.anchor_right = 1.0
		color_rect.anchor_bottom = 1.0
		color_rect.offset_left = 12
		color_rect.offset_top = 10
		color_rect.offset_right = -12
		color_rect.offset_bottom = -10
		
	# Colorear el texto de la bitácora
	var label_bitacora = panel.get_node_or_null("Label")
	if label_bitacora:
		label_bitacora.add_theme_color_override("font_color", texto_color)
		label_bitacora.add_theme_font_size_override("font_size", 10)
		
	# 2. Estilizar el Aviso de Interacción ("E - Inspeccionar")
	var estilo_aviso = StyleBoxTexture.new()
	estilo_aviso.texture = arte_hud
	# Region del cartel de mensaje (centro inferior)
	estilo_aviso.region_rect = Rect2(695, 651, 286, 75)
	estilo_aviso.texture_margin_left = 20
	estilo_aviso.texture_margin_right = 20
	estilo_aviso.texture_margin_top = 20
	estilo_aviso.texture_margin_bottom = 20
	
	etiqueta_aviso.add_theme_stylebox_override("normal", estilo_aviso)
	etiqueta_aviso.text = "" # Limpiamos nuestro texto para aprovechar el diseño pre-dibujado
	
	# Ajustar tamaño para que parezca un cartel
	etiqueta_aviso.custom_minimum_size = Vector2(140, 30)
	etiqueta_aviso.size = Vector2(140, 30)
	etiqueta_aviso.offset_left = -70
	etiqueta_aviso.offset_top = 50
	etiqueta_aviso.offset_right = 70
	etiqueta_aviso.offset_bottom = 80

