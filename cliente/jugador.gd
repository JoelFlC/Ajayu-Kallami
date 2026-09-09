extends CharacterBody3D

const VELOCIDAD = 5.0
const ALTURA_FIJA = 0.0
const GRAVEDAD = 9.8


func _ready() -> void:
	_registrar_accion_si_falta("mover_izquierda", KEY_A)
	_registrar_accion_si_falta("mover_derecha", KEY_D)
	_registrar_accion_si_falta("mover_arriba", KEY_W)
	_registrar_accion_si_falta("mover_abajo", KEY_S)


func _registrar_accion_si_falta(nombre: StringName, tecla: Key) -> void:
	if not InputMap.has_action(nombre):
		InputMap.add_action(nombre)
	if not InputMap.action_get_events(nombre).is_empty():
		return

	var evento := InputEventKey.new()
	evento.keycode = tecla
	evento.physical_keycode = tecla
	InputMap.action_add_event(nombre, evento)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVEDAD * delta

	var direccion := Input.get_vector("mover_izquierda", "mover_derecha", "mover_arriba", "mover_abajo")
	if direccion == Vector2.ZERO:
		var teclado := Vector2(
			float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)),
			float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W))
		)
		direccion = teclado.normalized()

	velocity.x = direccion.x * VELOCIDAD
	velocity.z = direccion.y * VELOCIDAD

	move_and_slide()
