extends Node

const CANDIDATOS = ["roqueria_alta", "quebrada_media", "paso_ladera_alta"]
const POZOS = ["pozo_1", "pozo_2", "pozo_3"]


func sortear_partida(semilla_fija: int = -1) -> Dictionary:
	var generador := RandomNumberGenerator.new()
	var semilla: int

	if semilla_fija == -1:
		generador.randomize()
		semilla = generador.seed
	else:
		generador.seed = semilla_fija
		semilla = semilla_fija

	var lugar_correcto: String = CANDIDATOS[generador.randi() % CANDIDATOS.size()]
	var pozo_jallu_uma: String = POZOS[generador.randi() % POZOS.size()]
	var testimonios: Dictionary = _generar_testimonios(lugar_correcto, generador)

	return {
		"semilla": semilla,
		"lugar_correcto": lugar_correcto,
		"pozo_jallu_uma": pozo_jallu_uma,
		"testimonios": testimonios
	}


func _generar_testimonios(lugar_correcto: String, generador: RandomNumberGenerator) -> Dictionary:
	var otros = CANDIDATOS.filter(func(candidato): return candidato != lugar_correcto)
	var indice_pastora: int = generador.randi() % otros.size()
	var candidato_pastora: String = otros[indice_pastora]
	otros.remove_at(indice_pastora)
	var candidato_comunario: String = otros[0]

	return {
		"pastora": {"candidato_mencionado": candidato_pastora, "confiable": false},
		"comunario": {"candidato_mencionado": candidato_comunario, "confiable": false},
		"niño_pastor": {"candidato_mencionado": lugar_correcto, "confiable": true}
	}
