extends Node2D

var jugador: CharacterBody2D
var apachetas: Array[Node] = []
var ofrenda_colocada: bool = false

func _ready() -> void:
	jugador = get_node_or_null("Entidades/Jugador")
	if not jugador:
		var jugadores = find_children("Jugador", "", true, false)
		if jugadores.size() > 0:
			jugador = jugadores[0]
			
	var zona = get_node_or_null("ZonaTrigger")
	if zona:
		var color_rect = zona.get_node_or_null("Color")
		if color_rect: color_rect.hide()
		zona.body_entered.connect(_on_zona_trigger_entered)

func _on_zona_trigger_entered(body: Node2D) -> void:
	if ofrenda_colocada or body != jugador:
		return
	ofrenda_colocada = true
	crear_particulas(jugador.global_position)

func crear_particulas(pos: Vector2) -> void:
	var particulas = CPUParticles2D.new()
	particulas.global_position = pos + Vector2(0, -10)
	particulas.amount = 30
	particulas.lifetime = 2.0
	particulas.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particulas.emission_sphere_radius = 10.0
	particulas.gravity = Vector2(0, -30)
	particulas.scale_amount_min = 2.0
	particulas.scale_amount_max = 4.0
	particulas.color = Color("efb44f") # Dorado cálido
	
	add_child(particulas)
	
	var luz = PointLight2D.new()
	luz.color = Color("efb44f")
	luz.energy = 1.5
	luz.texture = _crear_textura_luz()
	luz.texture_scale = 2.0
	particulas.add_child(luz)

func _crear_textura_luz() -> GradientTexture2D:
	var tex = GradientTexture2D.new()
	tex.width = 128
	tex.height = 128
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.8, 0.8)
	var grad = Gradient.new()
	grad.colors = PackedColorArray([Color(1,1,1,1), Color(0,0,0,0)])
	tex.gradient = grad
	return tex
