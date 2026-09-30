extends Node2D

func _ready() -> void:
	Engine.time_scale = 0.6
	
	# Desaturar
	var mod = CanvasModulate.new()
	mod.color = Color(0.3, 0.35, 0.4)
	add_child(mod)
	tree_exiting.connect(func(): Engine.time_scale = 1.0)
	var jugadores = find_children("Jugador", "", true, false)
	var jugador = jugadores[0] if jugadores.size() > 0 else null
	if not jugador: return
	
	# Instanciar el evento de susto pero extraer solo al fantasma (Nanqha)
	var evento_susto_scene = load("res://cliente/secuencias/susto/evento_susto.tscn")
	var evento = evento_susto_scene.instantiate()
	add_child(evento)
	
	# Posicionar el evento cerca del jugador
	evento.global_position = jugador.global_position + Vector2(-60, 40)
	
	# Ocultar la UI del susto para que no interrumpa
	var interfaz = evento.get_node_or_null("Interfaz")
	if interfaz: interfaz.hide()
	
	var nanqha = evento.get_node_or_null("Nanqha")
	if nanqha:
		# Reposicionar el nanqha relativo al evento
		nanqha.position = Vector2.ZERO
		# Hacer que aparezca luego de 1 segundo
		await get_tree().create_timer(1.0).timeout
		if nanqha.has_method("aparecer"):
			nanqha.aparecer(2.0)
