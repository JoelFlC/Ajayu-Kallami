extends Node2D

const LLUVIA: Texture2D = preload("res://cliente/efectos/clima/assets/Rain.png")
const SALPICADURA: Texture2D = preload("res://cliente/efectos/clima/assets/RainOnFloor.png")
const NIEVE: Texture2D = preload("res://cliente/efectos/clima/assets/Snow.png")
const SONIDO_LLUVIA: AudioStream = preload("res://cliente/efectos/clima/assets/Rain.wav")
const SONIDO_TORMENTA: AudioStream = preload("res://cliente/efectos/clima/assets/Storm.wav")
const SONIDO_VIENTO: AudioStream = preload("res://cliente/efectos/clima/assets/Wind2.wav")

# El mismo efecto sirve para la viñeta del ritual y para el pueblo exterior.
var tipo_agua: String = "jallu"
var area: Vector2 = Vector2(480, 270)

var gotas: Array[Dictionary] = []
var impactos: Array[Dictionary] = []
var generador := RandomNumberGenerator.new()
var sonido: AudioStreamPlayer
var tiempo: float = 0.0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if not tipo_agua in ["jallu", "chhijchi", "juyphi"]:
		push_warning("Tipo de agua desconocido para el efecto climático: " + tipo_agua)
		set_process(false)
		return
	generador.randomize()
	var cantidad := 150 if tipo_agua == "jallu" else 88 if tipo_agua == "chhijchi" else 50
	for indice in range(cantidad):
		gotas.append(_nueva_gota(true))
	sonido = AudioStreamPlayer.new()
	match tipo_agua:
		"jallu":
			sonido.stream = SONIDO_LLUVIA
			sonido.volume_db = -17.0
		"chhijchi":
			sonido.stream = SONIDO_TORMENTA
			sonido.volume_db = -21.0
		"juyphi":
			sonido.stream = SONIDO_VIENTO
			sonido.volume_db = -20.0
	add_child(sonido)
	sonido.finished.connect(_repetir_sonido)
	sonido.play()


func _nueva_gota(inicial: bool) -> Dictionary:
	var velocidad: float
	match tipo_agua:
		"jallu": velocidad = generador.randf_range(135.0, 205.0)
		"chhijchi": velocidad = generador.randf_range(115.0, 175.0)
		_: velocidad = 0.0
	var altura := generador.randf_range(-area.y, area.y) if inicial else generador.randf_range(-48.0, -8.0)
	if tipo_agua == "juyphi":
		altura = generador.randf_range(area.y * 0.82, area.y - 8.0)
	return {
		"posicion": Vector2(generador.randf_range(0.0, area.x), altura),
		"velocidad": velocidad,
		"suelo": generador.randf_range(maxf(area.y * 0.7, minf(160.0, area.y - 16.0)), area.y - 8.0),
		"desvio": generador.randf_range(-8.0, 8.0),
		"fase": generador.randf_range(0.0, TAU),
		"cuadro": generador.randi_range(0, 2 if tipo_agua == "jallu" else 6)
	}


func _process(delta: float) -> void:
	tiempo += delta
	for indice in range(gotas.size()):
		var gota: Dictionary = gotas[indice]
		var posicion: Vector2 = gota["posicion"]
		var desvio: float = gota["desvio"]
		if tipo_agua == "juyphi":
			posicion.x += sin(tiempo * 1.2 + float(gota["fase"])) * 1.5 * delta
		else:
			posicion.x += desvio * delta
			posicion.y += float(gota["velocidad"]) * delta
		if tipo_agua != "juyphi" and posicion.y >= float(gota["suelo"]):
			if tipo_agua != "juyphi" and impactos.size() < 48:
				impactos.append({"posicion": posicion, "edad": 0.0})
			gotas[indice] = _nueva_gota(false)
		else:
			if posicion.x < -8.0:
				posicion.x += area.x + 16.0
			elif posicion.x > area.x + 8.0:
				posicion.x -= area.x + 16.0
			gota["posicion"] = posicion
			gotas[indice] = gota
	for indice in range(impactos.size() - 1, -1, -1):
		impactos[indice]["edad"] = float(impactos[indice]["edad"]) + delta
		if float(impactos[indice]["edad"]) >= 0.24:
			impactos.remove_at(indice)
	queue_redraw()


func _draw() -> void:
	match tipo_agua:
		"jallu": draw_rect(Rect2(Vector2.ZERO, area), Color(0.16, 0.25, 0.36, 0.12))
		"chhijchi": draw_rect(Rect2(Vector2.ZERO, area), Color(0.20, 0.27, 0.38, 0.20))
		"juyphi":
			draw_rect(Rect2(Vector2.ZERO, area), Color(0.38, 0.56, 0.67, 0.22))
			draw_rect(Rect2(0, area.y * 0.82, area.x, area.y * 0.18), Color(0.75, 0.87, 0.94, 0.10))
	var textura := LLUVIA if tipo_agua == "jallu" else NIEVE
	var tinte := Color(0.68, 0.82, 0.95, 0.82) if tipo_agua == "jallu" else Color(0.85, 0.93, 1.0, 0.96)
	for gota in gotas:
		var posicion: Vector2 = gota["posicion"]
		var cuadro: int = gota["cuadro"]
		draw_texture_rect_region(textura, Rect2(posicion.round(), Vector2(8, 8)), Rect2(cuadro * 8, 0, 8, 8), tinte)
	for impacto in impactos:
		var cuadro := mini(int(float(impacto["edad"]) / 0.08), 2)
		draw_texture_rect_region(SALPICADURA, Rect2(Vector2(impacto["posicion"]).round(), Vector2(8, 8)), Rect2(cuadro * 8, 0, 8, 8), Color(0.85, 0.94, 1.0, 0.80))


func _repetir_sonido() -> void:
	if is_inside_tree() and is_instance_valid(sonido):
		sonido.play()


func _exit_tree() -> void:
	if is_instance_valid(sonido):
		sonido.stop()
