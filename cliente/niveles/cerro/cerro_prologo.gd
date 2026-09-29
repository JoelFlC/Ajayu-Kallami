extends Node2D

signal ajayu_perdido

# Desactivar en el inspector permite recorrer el mapa sin la escena del susto.
@export var evento_susto_habilitado: bool = true

@onready var abuelo: CharacterBody2D = $Entidades/Abuelo
@onready var evento: Node2D = $EventoSusto
@onready var zona: Area2D = $ZonaSusto/Activador

var prologo_terminado: bool = false
var etiquetas_ocultadas: Array[CanvasItem] = []


func _ready() -> void:
	zona.monitoring = evento_susto_habilitado
	zona.body_entered.connect(_al_entrar_al_claro)
	evento.iniciado.connect(_al_iniciar_susto)
	evento.terminado.connect(_al_perder_ajayu)
	_mostrar_indicacion()


# Punto de entrada reutilizable para un diálogo, trigger o controlador narrativo.
func iniciar_susto() -> bool:
	if not evento_susto_habilitado:
		return false
	return evento.iniciar(abuelo)


func _al_entrar_al_claro(cuerpo: Node2D) -> void:
	if cuerpo != abuelo:
		return
	# Al volver al inicio, física puede conservar un solapamiento un cuadro.
	# Se confirma la posición actual para no reactivar el susto por ese dato viejo.
	var forma: CollisionShape2D = $ZonaSusto/Activador/CollisionShape2D
	var caja := forma.shape as RectangleShape2D
	var limites := Rect2(-caja.size*0.5,caja.size).grow(8.0)
	if limites.has_point(forma.to_local(abuelo.global_position)):
		iniciar_susto()


func _al_iniciar_susto() -> void:
	zona.set_deferred("monitoring",false)
	$ZonaSusto/NombreClaro.hide()
	$Guia.hide()
	evento.aviso.show()
	# Los rótulos de trabajo no se superponen a la narración del prólogo.
	for etiqueta in $HitosCerro.find_children("*","Label",true,false):
		if etiqueta.visible:
			etiqueta.hide()
			etiquetas_ocultadas.append(etiqueta)


func _al_perder_ajayu() -> void:
	prologo_terminado = true
	ajayu_perdido.emit()


func reiniciar_prologo() -> bool:
	if not prologo_terminado or not evento.reiniciar():
		return false
	prologo_terminado = false
	abuelo.global_position = $Inicio.global_position
	var camara: Camera2D = abuelo.get_node("Camera2D")
	camara.reset_smoothing()
	camara.force_update_scroll()
	$ZonaSusto/NombreClaro.show()
	for etiqueta in etiquetas_ocultadas:
		if is_instance_valid(etiqueta):
			etiqueta.show()
	etiquetas_ocultadas.clear()
	zona.set_deferred("monitoring",evento_susto_habilitado)
	_mostrar_indicacion()
	return true


func _mostrar_indicacion() -> void:
	$Guia.show()
	evento.aviso.hide()
	$Guia/Ayuda.text = "WASD: caminar · Seguí el sendero hasta el Claro del cerro.\nEl susto se activa al entrar; R permite repetir al terminar." if evento_susto_habilitado else "WASD: caminar · Recorrido libre (susto desactivado).\nRoquería o quebrada → paso alto → tres pozos."


func _unhandled_key_input(evento_tecla: InputEvent) -> void:
	if evento_tecla is InputEventKey and evento_tecla.pressed and not evento_tecla.echo:
		if evento_tecla.physical_keycode == KEY_R and prologo_terminado:
			get_viewport().set_input_as_handled()
			reiniciar_prologo()
