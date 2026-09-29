extends Node2D

const HojaSustoScript = preload("res://cliente/secuencias/susto/hoja_susto.gd")
const ESCALA = HojaSustoScript.ESCALA
const LIENZO = HojaSustoScript.LIENZO
const INICIO = Vector2(215,145)

@onready var abuelo: CharacterBody2D = $Abuelo
@onready var sprite: AnimatedSprite2D = $Abuelo/AnimatedSprite2D
@onready var molde: AnimatedSprite2D = $MoldeAjayu
@onready var nanqha: Node2D = $Nanqha
@onready var ajayu: Node2D = $Ajayu
@onready var narracion: Label = $Interfaz/Panel/Margen/Texto
@onready var aviso: Label = $Interfaz/Aviso

var estado: StringName = &"listo"
var hoja_disponible: bool = false
var animacion: Tween


func _ready() -> void:
	abuelo.set_physics_process(false)
	abuelo.get_node("Camera2D").enabled = false
	var reajuste := Callable(abuelo,"_ajustar_frame")
	if sprite.animation_changed.is_connected(reajuste):
		sprite.animation_changed.disconnect(reajuste)
	_configurar_hoja()
	reiniciar()


func _configurar_hoja() -> void:
	var frames := HojaSustoScript.crear_frames()
	if frames == null:
		molde.sprite_frames = sprite.sprite_frames
		molde.animation = &"idle_perfil"
		molde.scale = sprite.scale
		return
	sprite.sprite_frames = frames
	molde.sprite_frames = frames
	molde.animation = &"susto"
	molde.frame = 0
	molde.scale = Vector2.ONE * ESCALA
	hoja_disponible = true


func reiniciar() -> void:
	if estado == &"reproduciendo":
		return
	if animacion != null and animacion.is_valid():
		animacion.kill()
	estado = &"listo"
	ajayu.reiniciar()
	nanqha.hide()
	$Ambiente.color = Color(0.68,0.72,0.82,1)
	abuelo.position = INICIO
	sprite.rotation = 0.0
	sprite.flip_h = false
	if hoja_disponible:
		sprite.scale = Vector2.ONE * ESCALA
		sprite.position = Vector2(0,-LIENZO.y*ESCALA*0.5)
		sprite.animation = &"susto"
		sprite.stop()
		sprite.frame = 0
	else:
		sprite.animation = &"idle_perfil"
		abuelo._ajustar_frame()
		sprite.play()
	molde.global_position = sprite.global_position
	molde.rotation = 0.0
	aviso.text = "PRUEBA VISUAL · Enter o E: iniciar · R: repetir al terminar"
	narracion.text = "El abuelo regresaba del cerro cuando sintió una presencia detrás del silencio…"
	if not hoja_disponible:
		aviso.text += "\nHoja pendiente: caída provisional."


func _unhandled_key_input(evento: InputEvent) -> void:
	if evento is InputEventKey and evento.pressed and not evento.echo:
		if evento.physical_keycode in [KEY_ENTER,KEY_E,KEY_SPACE] and estado == &"listo":
			get_viewport().set_input_as_handled()
			iniciar()
		elif evento.physical_keycode == KEY_R and estado != &"reproduciendo":
			get_viewport().set_input_as_handled()
			reiniciar()


func iniciar() -> void:
	if estado != &"listo":
		return
	estado = &"reproduciendo"
	aviso.text = "PRUEBA VISUAL · Secuencia del susto en reproducción"
	narracion.text = "Una Ñanqha apareció ante él. El susto le quitó las fuerzas."
	nanqha.aparecer(1.0)
	animacion = create_tween()
	animacion.tween_property($Ambiente,"color",Color(0.4,0.46,0.62,1),1.0)
	await get_tree().create_timer(0.9).timeout
	if hoja_disponible:
		sprite.play(&"susto")
		await sprite.animation_finished
		sprite.play(&"caida")
		await sprite.animation_finished
		sprite.play(&"caido")
	else:
		animacion = create_tween().set_parallel(true)
		animacion.tween_property(sprite,"rotation",-PI*0.5,0.75)
		animacion.tween_property(sprite,"position",Vector2(-6,-4),0.75)
		await animacion.finished
	await get_tree().create_timer(0.35).timeout
	narracion.text = "Su ajayu se apartó del cuerpo. El abuelo quedó tendido en el camino."
	aviso.text = "PRUEBA VISUAL · Separación del ajayu"
	molde.global_position = abuelo.global_position + Vector2(-3,-14)
	ajayu.separar_desde(molde,abuelo.global_position+Vector2(20,-78),3.6)
	nanqha.desvanecer(2.0)
	await ajayu.separacion_terminada
	estado = &"terminado"
	narracion.text = "El ajayu quedó en el cerro. Al volver al pueblo, su familia tendría que buscar ayuda."
	aviso.text = "PRUEBA TERMINADA · R: reiniciar · Enter: después de reiniciar"
