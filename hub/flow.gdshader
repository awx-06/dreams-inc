shader_type canvas_item;

uniform vec2 center = vec2(0.5);
uniform float swirl_strength : hint_range(-2.0, 2.0, 0.1) = 1.2;
uniform float rotation_degrees : hint_range(-2880.0, 2880.0, 360.0) = -1080.0;
uniform float progress : hint_range(0.0, 1.0) = 0.0;

vec2 rotate_vec2(vec2 vec, float angle_degrees) {
	float a = radians(-angle_degrees);
	return vec2(
		vec.x * cos(a) - vec.y * sin(a),
		vec.y * cos(a) + vec.x * sin(a)
	);
}

void fragment() {
	vec2 coords = UV - center;
	float dist = length(coords);
	float modificator = pow(progress, 2.0 - dist * swirl_strength);
	coords = rotate_vec2(coords, rotation_degrees * modificator);
	coords += center;
	vec4 col = texture(TEXTURE, coords);
	col.a *= 1.0 - progress;
	COLOR = col;
}