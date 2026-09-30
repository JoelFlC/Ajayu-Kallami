extends Control

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is TextureRect

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	# Mueve el item original al centro de esta zona
	data.get_parent().remove_child(data)
	add_child(data)
	data.position = (size - data.size) / 2.0
	
	# Efecto visual
	var particulas = CPUParticles2D.new()
	particulas.position = size / 2.0
	particulas.amount = 20
	particulas.lifetime = 1.0
	particulas.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particulas.emission_sphere_radius = 20.0
	particulas.spread = 180.0
	particulas.gravity = Vector2.ZERO
	particulas.initial_velocity_min = 20.0
	particulas.initial_velocity_max = 50.0
	particulas.color = Color("efb44f")
	add_child(particulas)
