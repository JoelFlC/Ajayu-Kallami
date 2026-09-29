extends Node2D

# Figuras temporales sin arte externo; se reemplazarán por sprites reales.
func _draw() -> void:
	var madera := Color("684337")
	var piel := Color("c89e79")
	var pelo := Color("c9c9bd")
	# Abuelo recostado: almohada, cabeza y manta sobre una cama.
	draw_rect(Rect2(-14, -23, 28, 26), madera)
	draw_rect(Rect2(-12, -21, 24, 6), Color("d1c5a6"))
	draw_rect(Rect2(-4, -21, 8, 4), pelo)
	draw_rect(Rect2(-4, -17, 8, 5), piel)
	draw_rect(Rect2(-11, -12, 22, 12), Color("715977"))
	draw_rect(Rect2(-11, -9, 22, 2), Color("c09271"))
	draw_rect(Rect2(-13, 2, 3, 3), madera)
	draw_rect(Rect2(10, 2, 3, 3), madera)
	# Abuela de pie, al lado de la cama (origen en los pies).
	var p: Vector2 = $Abuela.position
	draw_rect(Rect2(p + Vector2(-4, -25), Vector2(8, 5)), pelo)
	draw_rect(Rect2(p + Vector2(-4, -20), Vector2(8, 6)), piel)
	draw_rect(Rect2(p + Vector2(-6, -14), Vector2(12, 8)), Color("963e4d"))
	draw_rect(Rect2(p + Vector2(-7, -6), Vector2(14, 5)), Color("3d5862"))
	draw_rect(Rect2(p + Vector2(-5, -1), Vector2(4, 3)), madera)
	draw_rect(Rect2(p + Vector2(1, -1), Vector2(4, 3)), madera)
