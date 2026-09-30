extends Node2D

var jugador: CharacterBody2D
var apachetas: Array[Node] = []
var mesa_entregada = false

func _ready() -> void:
	var jugadores = find_children("Jugador", "", true, false)
	jugador = jugadores[0] if jugadores.size() > 0 else null
	
	var zona = get_node_or_null("ZonaTrigger")
	if zona:
		var color_rect = zona.get_node_or_null("Color")
		if color_rect: color_rect.hide()
		zona.body_entered.connect(_on_zona_trigger_entered)
		# Añadir visualmente los items en el suelo dentro de la zona para prepararse
		_crear_item_suelo(Rect2(505, 778, 76, 64), zona.global_position + Vector2(-15, 10)) # Prenda
		_crear_item_suelo(Rect2(621, 782, 78, 59), zona.global_position + Vector2(15, 15))  # Tierra

func _crear_item_suelo(region: Rect2, pos: Vector2) -> void:
	var tex = preload("res://cliente/sprites/ui/hud_andino.png")
	var sprite = Sprite2D.new()
	var atlas = AtlasTexture.new()
	atlas.atlas = tex
	atlas.region = region
	sprite.texture = atlas
	sprite.global_position = pos
	sprite.scale = Vector2(0.5, 0.5) # Hacerlos pequeños en el suelo
	add_child(sprite)

func _on_zona_trigger_entered(body: Node2D) -> void:
	if mesa_entregada or body != jugador: return
	mesa_entregada = true
	
	# Ocultar items y mostrar particulas
	for c in get_children():
		if c is Sprite2D:
			var t = create_tween()
			t.tween_property(c, "modulate:a", 0.0, 1.0)
			
	var particulas = CPUParticles2D.new()
	var zona = get_node_or_null("ZonaTrigger")
	particulas.global_position = zona.global_position + Vector2(0, -10) if zona else jugador.global_position
	particulas.amount = 40
	particulas.lifetime = 2.0
	particulas.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particulas.emission_sphere_radius = 15.0
	particulas.gravity = Vector2(0, -40)
	particulas.color = Color("efb44f")
	add_child(particulas)
