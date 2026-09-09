extends Node

var _es_servidor := false


func _ready() -> void:
	_es_servidor = "--servidor" in OS.get_cmdline_args()

	if _es_servidor:
		_iniciar_servidor()
	else:
		_iniciar_cliente()


func _iniciar_servidor() -> void:
	var peer := ENetMultiplayerPeer.new()
	var resultado := peer.create_server(Protocolo.PUERTO)

	if resultado != OK:
		push_error("No se pudo iniciar el servidor: " + str(resultado))
		return

	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_al_conectar_cliente)
	print("Servidor escuchando en puerto " + str(Protocolo.PUERTO))


func _iniciar_cliente() -> void:
	var peer := ENetMultiplayerPeer.new()
	var resultado := peer.create_client(Protocolo.IP_LOCAL, Protocolo.PUERTO)

	if resultado != OK:
		push_error("No se pudo iniciar el cliente: " + str(resultado))
		return

	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_al_conectar_servidor)


func _al_conectar_cliente(id: int) -> void:
	print("Cliente conectado con id: " + str(id))


func _al_conectar_servidor() -> void:
	print("¡Conectado al servidor!")
	mover.rpc_id(1, Vector2(10, 20))


@rpc("any_peer")
func mover(posicion: Vector2) -> void:
	if _es_servidor:
		var id := multiplayer.get_remote_sender_id()
		print("Jugador " + str(id) + " dice que está en " + str(posicion))
	else:
		pass
