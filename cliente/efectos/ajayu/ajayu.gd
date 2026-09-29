extends Node2D

signal separacion_terminada

@onready var eco: Sprite2D = $Eco

var activo: bool = false
var progreso: float = 0.0
var tiempo: float = 0.0
var animacion: Tween


func _ready() -> void:
	hide()
	set_process(false)


func separar_desde(sprite: AnimatedSprite2D, destino_global: Vector2, duracion: float = 3.6) -> void:
	reiniciar()
	if sprite.sprite_frames == null:
		return
	eco.texture = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	eco.scale = sprite.global_scale
	eco.flip_h = sprite.flip_h
	eco.flip_v = sprite.flip_v
	eco.rotation = sprite.global_rotation
	global_position = sprite.global_position
	progreso = 0.0
	tiempo = 0.0
	activo = true
	show()
	set_process(true)
	animacion = create_tween().set_parallel(true)
	animacion.tween_property(self, "global_position", destino_global, duracion).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	animacion.tween_property(self, "progreso", 1.0, duracion)
	animacion.tween_property(self, "scale", Vector2(1.12, 1.12), duracion)
	animacion.tween_property(self, "modulate:a", 0.0, duracion * 0.35).set_delay(duracion * 0.65)
	animacion.chain().tween_callback(_terminar)


func reiniciar() -> void:
	if animacion != null and animacion.is_valid():
		animacion.kill()
	activo = false
	scale = Vector2.ONE
	modulate = Color.WHITE
	hide()
	set_process(false)


func _terminar() -> void:
	activo = false
	hide()
	set_process(false)
	separacion_terminada.emit()


func _process(delta: float) -> void:
	tiempo += delta
	queue_redraw()


func _draw() -> void:
	if not activo:
		return
	var pulso := 0.9 + sin(tiempo * 4.0) * 0.1
	# Halo escalonado y destellos en píxeles: sin imagen ni textura generada.
	for i in range(4, 0, -1):
		var radio := Vector2(7 + i * 2, 13 + i * 2)
		var puntos := PackedVector2Array([
			Vector2(-radio.x, -radio.y * 0.5), Vector2(-radio.x * 0.5, -radio.y),
			Vector2(radio.x * 0.5, -radio.y), Vector2(radio.x, -radio.y * 0.5),
			Vector2(radio.x, radio.y * 0.5), Vector2(radio.x * 0.5, radio.y),
			Vector2(-radio.x * 0.5, radio.y), Vector2(-radio.x, radio.y * 0.5)
		])
		draw_colored_polygon(puntos, Color(0.4, 0.77, 0.91, 0.025 * pulso))
	for i in range(18):
		var fase := fmod(tiempo * 0.45 + i * 0.071, 1.0)
		var x := roundf(sin(i * 2.4 + tiempo * 1.5) * (6.0 + fase * 7.0))
		var y := roundf(28.0 - fase * 52.0)
		var alpha := sin(fase * PI) * (0.35 + progreso * 0.2)
		var color := Color(0.88, 0.97, 1.0, alpha)
		draw_rect(Rect2(Vector2(x, y), Vector2.ONE if i % 3 else Vector2(2, 2)), color)
