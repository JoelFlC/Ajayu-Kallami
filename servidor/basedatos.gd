extends Node

const RUTA_ARCHIVO = "user://ajayu_basedatos.json"

var datos: Dictionary = {
	"usuarios": [],
	"partidas": [],
	"progreso": [],
	"resultados": []
}


func _ready() -> void:
	cargar()


func cargar() -> void:
	print("Ruta real del archivo: ", ProjectSettings.globalize_path(RUTA_ARCHIVO))
	if not FileAccess.file_exists(RUTA_ARCHIVO):
		guardar()
		return

	var archivo := FileAccess.open(RUTA_ARCHIVO, FileAccess.READ)
	if archivo == null:
		return

	var datos_leidos = JSON.parse_string(archivo.get_as_text())
	if datos_leidos is Dictionary:
		datos = datos_leidos


func guardar() -> void:
	var archivo := FileAccess.open(RUTA_ARCHIVO, FileAccess.WRITE)
	if archivo == null:
		return

	archivo.store_string(JSON.stringify(datos, "\t"))


func buscar_usuario(nombre_usuario: String) -> Dictionary:
	for usuario in datos["usuarios"]:
		if usuario.get("usuario", "") == nombre_usuario:
			return usuario

	return {}


func agregar_usuario(nombre_usuario: String, hash_contraseña: String, salt: String) -> void:
	var nuevo_usuario := {
		"id": datos["usuarios"].size() + 1,
		"usuario": nombre_usuario,
		"hash_contraseña": hash_contraseña,
		"salt": salt,
		"creado_en": Time.get_datetime_string_from_system()
	}
	datos["usuarios"].append(nuevo_usuario)
	guardar()
