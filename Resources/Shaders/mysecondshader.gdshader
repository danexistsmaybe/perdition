shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 a = texture(screen_texture, SCREEN_UV + TEXTURE_PIXEL_SIZE * vec2(-1.0, -1.0));
	vec4 b = texture(screen_texture, SCREEN_UV + TEXTURE_PIXEL_SIZE * vec2( 0.0, -1.0));
	vec4 c = texture(screen_texture, SCREEN_UV + TEXTURE_PIXEL_SIZE * vec2( 1.0, -1.0));

	vec4 d = texture(screen_texture, SCREEN_UV + TEXTURE_PIXEL_SIZE * vec2(-1.0,  0.0));
	vec4 e = texture(screen_texture, SCREEN_UV); // center
	vec4 f = texture(screen_texture, SCREEN_UV + TEXTURE_PIXEL_SIZE * vec2( 1.0,  0.0));

	vec4 g = texture(screen_texture, SCREEN_UV + TEXTURE_PIXEL_SIZE * vec2(-1.0,  1.0));
	vec4 h = texture(screen_texture, SCREEN_UV + TEXTURE_PIXEL_SIZE * vec2( 0.0,  1.0));
	vec4 i = texture(screen_texture, SCREEN_UV + TEXTURE_PIXEL_SIZE * vec2( 1.0,  1.0));

	vec4 o = e + (sin(TIME*PI/2.0)/4.0 + .25)*(5.0*e - (a+b+c+d+f+g+h+i));
	o.a = 1.0;
	COLOR = o;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
