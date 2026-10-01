extends SceneTree

const JUEGO = preload("res://cliente/juego_local.tscn")


func _initialize() -> void:
	call_deferred("_probar")


func _probar() -> void:
	var juego := JUEGO.instantiate()
	root.add_child(juego)
	juego._mostrar_pueblo(false)
	var pueblo: Node = juego.escenario_actual
	var mision: Node = pueblo.get_child(pueblo.get_child_count() - 1)
	var jugador: CharacterBody2D = pueblo.get_node("Node2D/Jugador")
	assert(mision.en_casa)
	assert(jugador.get("velocidad_movimiento") == 80.0)
	mision._salir_casa()
	assert(not mision.en_casa)
	assert(jugador.get("velocidad_movimiento") == 150.0)
	mision._entrar_casa()
	assert(mision.en_casa)
	assert(jugador.get("velocidad_movimiento") == 80.0)
	print("Velocidad: casa 80, exterior 150, regreso a casa 80 OK")
	quit()
