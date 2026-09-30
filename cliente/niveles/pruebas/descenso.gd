extends Node2D

func _ready() -> void:
	# Bajar la velocidad general del motor (crea un efecto dramático y lento)
	Engine.time_scale = 0.5
	
	# Desaturar la pantalla (CanvasModulate oscurece la pantalla entera)
	var canvas_modulate = CanvasModulate.new()
	canvas_modulate.color = Color(0.3, 0.3, 0.35) # Tono gris oscuro azulado
	add_child(canvas_modulate)
	
	# Restaurar el time_scale al salir para no afectar el editor o siguientes pruebas
	tree_exiting.connect(func(): Engine.time_scale = 1.0)
