shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = texture(
		screen_texture,
		floor(SCREEN_UV*vec2(320.,180))/vec2(320.,180.)
	);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
