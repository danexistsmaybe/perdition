shader_type canvas_item;

uniform sampler2D noise : repeat_enable;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 pixel_uv = floor(UV * 128.*10.)/(128.*10.);
	
	float sample1 = .5*texture(noise, pixel_uv + .05*TIME*vec2(0.05,0.05)).x;
	float sample2 = .5*texture(noise, pixel_uv + 100. + .05*TIME*vec2(0.00,-.1)).x;
	
	COLOR = floor(vec4(
		vec3(sample1 + sample2),
		.09+.15*sample1 + .1*sample2
	)*15.)/15.;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
