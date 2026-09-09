extends Node

var base_datos: Node


func _generar_salt() -> String:
	return Crypto.new().generate_random_bytes(16).hex_encode()


func _hashear(contraseña: String, salt: String) -> String:
	var contexto := HashingContext.new()
	contexto.start(HashingContext.HASH_SHA256)
	contexto.update((salt + contraseña).to_utf8_buffer())
	return contexto.finish().hex_encode()


func registrar(nombre_usuario: String, contraseña: String) -> Dictionary:
	if base_datos.buscar_usuario(nombre_usuario).size() > 0:
		return {"exito": false, "mensaje": "El usuario ya existe"}

	var salt := _generar_salt()
	var hash_contraseña := _hashear(contraseña, salt)
	base_datos.agregar_usuario(nombre_usuario, hash_contraseña, salt)
	return {"exito": true, "mensaje": "Usuario registrado"}


func iniciar_sesion(nombre_usuario: String, contraseña: String) -> Dictionary:
	var usuario: Dictionary = base_datos.buscar_usuario(nombre_usuario)
	if usuario.size() == 0:
		return {"exito": false, "mensaje": "Usuario no encontrado"}

	var hash_recibido := _hashear(contraseña, usuario["salt"])
	if hash_recibido == usuario["hash_contraseña"]:
		return {"exito": true, "mensaje": "Login correcto"}

	return {"exito": false, "mensaje": "Contraseña incorrecta"}
