extends Node

const SorteoScript = preload("res://servidor/sorteo.gd")
const BaseDatosScript = preload("res://servidor/basedatos.gd")
const AuthScript = preload("res://servidor/auth.gd")

var _es_servidor := false
var base_datos
var auth
var sorteo


func _ready() -> void:
	_es_servidor = "--servidor" in OS.get_cmdline_args()

	if _es_servidor:
		_iniciar_servidor()
	else:
		_iniciar_cliente()


func _iniciar_servidor() -> void:
	base_datos = BaseDatosScript.new()
	add_child(base_datos)
	auth = AuthScript.new()
	auth.base_datos = base_datos
	add_child(auth)
	sorteo = SorteoScript.new()
	add_child(sorteo)

	var partida_actual = sorteo.sortear_partida()
	print("=== SORTEO DE LA PARTIDA ===")
	print("Semilla: ", partida_actual["semilla"])
	print("Lugar correcto: ", partida_actual["lugar_correcto"])
	print("Pozo jallu uma: ", partida_actual["pozo_jallu_uma"])
	print("Testimonios: ", JSON.stringify(partida_actual["testimonios"], "  "))

	print("=== PRUEBA DE DETERMINISMO (semilla fija 12345, dos corridas) ===")
	var prueba1 = sorteo.sortear_partida(12345)
	var prueba2 = sorteo.sortear_partida(12345)
	print("Prueba 1: ", prueba1["lugar_correcto"], " / ", prueba1["pozo_jallu_uma"])
	print("Prueba 2: ", prueba2["lugar_correcto"], " / ", prueba2["pozo_jallu_uma"])
	print("¿Coinciden?: ", prueba1["lugar_correcto"] == prueba2["lugar_correcto"] and prueba1["pozo_jallu_uma"] == prueba2["pozo_jallu_uma"])

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
	registrar_rpc.rpc_id(1, "angel_test", "clave123")
	iniciar_sesion_rpc.rpc_id(1, "angel_test", "clave123")


@rpc("any_peer")
func mover(posicion: Vector2) -> void:
	if _es_servidor:
		var id := multiplayer.get_remote_sender_id()
		print("Jugador " + str(id) + " dice que está en " + str(posicion))
	else:
		pass


@rpc("any_peer")
func registrar_rpc(usuario: String, contraseña: String) -> void:
	if not _es_servidor:
		return

	var id_remitente := multiplayer.get_remote_sender_id()
	var resultado: Dictionary = auth.registrar(usuario, contraseña)
	resultado_login.rpc_id(id_remitente, resultado["exito"], resultado["mensaje"])


@rpc("any_peer")
func iniciar_sesion_rpc(usuario: String, contraseña: String) -> void:
	if not _es_servidor:
		return

	var id_remitente := multiplayer.get_remote_sender_id()
	var resultado: Dictionary = auth.iniciar_sesion(usuario, contraseña)
	resultado_login.rpc_id(id_remitente, resultado["exito"], resultado["mensaje"])


@rpc("any_peer")
func resultado_login(exito: bool, mensaje: String) -> void:
	if _es_servidor:
		return

	print("Resultado del login: ", exito, " - ", mensaje)
