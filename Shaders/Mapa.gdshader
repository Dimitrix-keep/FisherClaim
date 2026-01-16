shader_type canvas_item;

uniform float speed = 1.0;
uniform float amplitude = 5.0;
uniform float frequency = 10.0;

void fragment() {
    vec2 uv = UV;
    uv.y += sin(uv.x * frequency + TIME * speed) * (amplitude / 100.0);
    COLOR = texture(TEXTURE, uv);
}


//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
