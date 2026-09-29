shader_type canvas_item;
render_mode unshaded;

uniform vec4 tono : source_color = vec4(0.68, 0.91, 1.0, 0.82);
varying vec4 color_nodo;

void vertex() {
	color_nodo = COLOR;
}

void fragment() {
	vec4 muestra = texture(TEXTURE, UV);
	float pulso = 0.92 + sin(TIME * 4.0) * 0.08;
	COLOR = vec4(tono.rgb * pulso, muestra.a * tono.a) * color_nodo;
}
