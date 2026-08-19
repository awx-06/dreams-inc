shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.10;
uniform float scanline_count = 180.0;
uniform float aberration : hint_range(0.0, 3.0) = 0.8;
uniform float vignette : hint_range(0.0, 1.0) = 0.35;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 off = vec2(aberration * SCREEN_PIXEL_SIZE.x, 0.0);
	float r = texture(screen_tex, uv + off).r;
	float g = texture(screen_tex, uv).g;
	float b = texture(screen_tex, uv - off).b;
	vec3 col = vec3(r, g, b);
	float scan = sin(uv.y * scanline_count * 3.14159) * 0.5 + 0.5;
	col *= 1.0 - scan * scanline_strength;
	vec2 vc = uv - 0.5;
	col *= 1.0 - dot(vc, vc) * vignette * 2.0;
	COLOR = vec4(col, 1.0);
}