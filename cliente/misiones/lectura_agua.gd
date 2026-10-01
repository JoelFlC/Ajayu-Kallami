extends RefCounted

# Los rasgos son diseño del juego, no descripciones del testimonio oral.
const TIPOS = ["jallu", "chhijchi", "juyphi"]
const CATEGORIAS = ["Color", "Sonido", "Aire", "Vegetación", "Olor"]
const OPCIONES = [
	["gris moteado", "verde azulado", "azul pálido"],
	["silencio", "golpes secos", "murmullo"],
	["frío cortante", "helado", "templado"],
	["brotes húmedos", "escarcha", "hierba quebrada"],
	["piedra húmeda", "tierra mojada", "casi sin olor"]
]
const RESPUESTAS = {
	"jallu": [2, 3, 3, 1, 2],
	"chhijchi": [1, 2, 1, 3, 1],
	"juyphi": [3, 1, 2, 2, 3]
}
const INTERPRETACIONES = {
	"jallu": "Las señas recuerdan al agua que alimenta la lluvia.",
	"chhijchi": "Las señas anuncian granizo, no lluvia mansa.",
	"juyphi": "Las señas hablan de helada y quietud."
}


static func tipo_de_pozo(pozo: String, pozo_jallu: String) -> String:
	# La asignación de las dos aguas restantes es estable para la partida.
	var pozos := ["pozo_1", "pozo_2", "pozo_3"]
	if not pozos.has(pozo) or not pozos.has(pozo_jallu):
		return ""
	if pozo == pozo_jallu:
		return "jallu"
	pozos.erase(pozo_jallu)
	return "chhijchi" if pozo == pozos[0] else "juyphi"


static func evaluar(tipo_real: String, seleccion: Array) -> Dictionary:
	if not TIPOS.has(tipo_real) or seleccion.size() != CATEGORIAS.size():
		return {"calidad": "invalida", "texto": "No puedo leer estas señas."}
	var esperado: Array = RESPUESTAS[tipo_real]
	var correctos := 0
	var errores := 0
	var marcados := 0
	for indice in range(CATEGORIAS.size()):
		var valor: int = int(seleccion[indice])
		if valor < 0 or valor > 3:
			return {"calidad": "invalida", "texto": "No puedo leer estas señas."}
		if valor == 0:
			continue
		marcados += 1
		if valor == esperado[indice]:
			correctos += 1
		else:
			errores += 1
	if marcados == 0:
		return {"calidad": "incompleta", "texto": "No marcaste ninguna seña. Examina el pozo y anota lo que percibes."}
	if errores >= 2:
		return {"calidad": "contradictoria", "texto": "Hay señas que se contradicen. Vuelve a mirar el agua y sus alrededores."}
	if correctos >= 4 and errores == 0:
		return {"calidad": "clara", "texto": INTERPRETACIONES[tipo_real]}
	return {"calidad": "dudosa", "texto": "Hay indicios, pero la lectura sigue dudosa. Faltan detalles o uno no encaja."}
