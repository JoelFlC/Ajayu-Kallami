extends Node2D

signal iniciado
signal terminado

const HojaSustoScript = preload("res://cliente/secuencias/susto/hoja_susto.gd")

# Reutiliza la iluminación del mapa para no superponer dos CanvasModulate.
@export var ambiente_externo: NodePath

@onready var nanqha: Node2D = $Nanqha
@onready var ajayu: Node2D = $Ajayu
@onready var molde: AnimatedSprite2D = $MoldeAjayu
@onready var panel: PanelContainer = $Interfaz/Panel
@onready var narracion: Label = $Interfaz/Panel/Texto
@onready var aviso: Label = $Interfaz/Aviso

var estado: StringName = &"listo"
var abuelo: CharacterBody2D
var sprite: AnimatedSprite2D
var original: Dictionary = {}
var animacion: Tween
var reajuste: Callable
var ambiente: CanvasModulate
var color_ambiente_original: Color


func _ready() -> void:
	panel.hide()
	nanqha.hide()
	if not ambiente_externo.is_empty():
		ambiente = get_node_or_null(ambiente_externo) as CanvasModulate
	if ambiente == null:
		ambiente = CanvasModulate.new()
		ambiente.name = "Ambiente"
		add_child(ambiente)
	color_ambiente_original = ambiente.color


# El mapa entrega su abuelo real: no se crea un segundo personaje ni cámara.
func iniciar(personaje: CharacterBody2D) -> bool:
	if estado != &"listo" or not is_instance_valid(personaje):
		return false
	var visual := personaje.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if visual == null:
		return false
	var frames := HojaSustoScript.crear_frames()
	if frames == null:
		return false
	abuelo = personaje
	sprite = visual
	reajuste = Callable(abuelo,"_ajustar_frame")
	original = {
		"frames": sprite.sprite_frames, "animation": sprite.animation,
		"frame": sprite.frame, "progress": sprite.frame_progress,
		"playing": sprite.is_playing(), "scale": sprite.scale,
		"position": sprite.position, "rotation": sprite.rotation,
		"flip_h": sprite.flip_h, "flip_v": sprite.flip_v,
		"speed_scale": sprite.speed_scale,
		"physics": abuelo.is_physics_processing(), "controlable": abuelo.controlable,
		"reajuste": sprite.animation_changed.is_connected(reajuste)
	}
	estado = &"reproduciendo"
	abuelo.controlable = false
	abuelo.velocity = Vector2.ZERO
	abuelo.set_physics_process(false)
	if original["reajuste"]:
		sprite.animation_changed.disconnect(reajuste)
	sprite.stop()
	sprite.sprite_frames = frames
	sprite.scale = Vector2.ONE*HojaSustoScript.ESCALA
	sprite.position = Vector2(0,-HojaSustoScript.LIENZO.y*HojaSustoScript.ESCALA*0.5)
	sprite.rotation = 0.0
	sprite.flip_h = false
	sprite.flip_v = false
	sprite.speed_scale = 1.0
	sprite.animation = &"susto"
	sprite.frame = 0
	molde.sprite_frames = frames
	molde.animation = &"susto"
	molde.frame = 0
	molde.scale = sprite.scale
	nanqha.global_position = abuelo.global_position+Vector2(38,-3)
	panel.show()
	narracion.text = "El abuelo regresaba del cerro cuando sintió una presencia detrás del silencio…"
	aviso.text = "PRÓLOGO · El susto"
	iniciado.emit()
	_reproducir()
	return true


func _reproducir() -> void:
	animacion = create_tween()
	animacion.tween_property(ambiente,"color",Color(0.4,0.46,0.62,1),1.0)
	nanqha.aparecer(1.0)
	await get_tree().create_timer(1.15).timeout
	narracion.text = "Una Ñanqha apareció ante él. El susto le quitó las fuerzas."
	sprite.play(&"susto")
	await sprite.animation_finished
	sprite.play(&"caida")
	await sprite.animation_finished
	sprite.play(&"caido")
	await get_tree().create_timer(0.35).timeout
	narracion.text = "Su ajayu se apartó del cuerpo. El abuelo quedó tendido en el camino."
	molde.global_position = abuelo.global_position+Vector2(-3,-14)
	ajayu.separar_desde(molde,abuelo.global_position+Vector2(20,-78),3.6)
	nanqha.desvanecer(2.0)
	await ajayu.separacion_terminada
	estado = &"terminado"
	narracion.text = "Al volver al pueblo, su familia tendría que buscar ayuda para llamar a su ajayu."
	aviso.text = "FIN DEL PRÓLOGO · R: repetir desde el inicio"
	terminado.emit()


# Solo se reinicia al terminar: evita corutinas de una reproducción anterior.
func reiniciar() -> bool:
	if estado == &"reproduciendo":
		return false
	if animacion != null and animacion.is_valid():
		animacion.kill()
	ajayu.reiniciar()
	nanqha.hide()
	ambiente.color = color_ambiente_original
	panel.hide()
	if is_instance_valid(abuelo) and not original.is_empty():
		sprite.stop()
		sprite.sprite_frames = original["frames"]
		sprite.animation = original["animation"]
		sprite.set_frame_and_progress(original["frame"],original["progress"])
		sprite.scale = original["scale"]
		sprite.position = original["position"]
		sprite.rotation = original["rotation"]
		sprite.flip_h = original["flip_h"]
		sprite.flip_v = original["flip_v"]
		sprite.speed_scale = original["speed_scale"]
		if original["playing"]:
			sprite.play()
		if original["reajuste"] and not sprite.animation_changed.is_connected(reajuste):
			sprite.animation_changed.connect(reajuste)
		abuelo.controlable = original["controlable"]
		abuelo.velocity = Vector2.ZERO
		abuelo.set_physics_process(original["physics"])
	original.clear()
	estado = &"listo"
	return true
