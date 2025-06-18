shader_type canvas_item;

uniform sampler2D noise : repeat_enable;
uniform sampler2D warp_noise : repeat_enable;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 center = vec2(0.5);
	vec2 delta = UV - center;
	
	float radius = length(delta);          // distance from center
	float angle = atan(delta.y, delta.x);  // angle in radians
	
	vec2 radial_uv = vec2((angle + PI) / (2.0 * PI), radius);
	
	float warp = texture(warp_noise, radial_uv).x;
	
	float sample = texture(noise, (radial_uv*vec2(4,1)) + vec2(0,.04*TIME) + vec2(warp)).r;
	
	COLOR = 0.*vec4(0,0,0,pow(radius,.5)) + (vec4(0,0,0,2.*pow(radius + (sin(TIME)*.1-.2) - .1*warp, .5) - 1.*sample*sample*sample));
	
	/*if (sample < .5) {
		COLOR = vec4(0,0,0,3.*radius) + vec4(0,0,0,radius - sample);
	} else {
		COLOR = vec4(0,0,0,3.0*radius);
	}*/
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
