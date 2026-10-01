extends StaticBody2D

# Cierra el borde que quedó expuesto al retirar el terreno del pueblo.
# Las demás paredes de roca del cerro siguen en BordesTerreno.
@export var ruta_terreno: NodePath = NodePath("../Pasto")


func _ready() -> void:
	var terreno := get_node_or_null(ruta_terreno) as TileMapLayer
	if terreno == null or terreno.tile_set == null:
		push_error("BordePieCerro necesita la capa Pasto")
		return

	var mitad := Vector2(terreno.tile_set.tile_size) * 0.5
	for celda in terreno.get_used_cells():
		if celda.y < -30:
			continue
		for direccion in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]:
			if terreno.get_cell_source_id(celda + direccion) != -1:
				continue
			var forma := RectangleShape2D.new()
			forma.size = Vector2(terreno.tile_set.tile_size.x, 4.0) if direccion.y != 0 else Vector2(4.0, terreno.tile_set.tile_size.y)
			var colision := CollisionShape2D.new()
			colision.shape = forma
			colision.position = to_local(terreno.to_global(terreno.map_to_local(celda))) + Vector2(direccion) * mitad
			add_child(colision)
