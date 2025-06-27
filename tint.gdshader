shader_type canvas_item;

uniform vec4 color: source_color = vec4( 1.0, 1.0, 1.0, 1.0 );
uniform float tint_factor: hint_range(0.0, 1.0) = 0.5;
uniform float fade: hint_range(0.0, 1.0) = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 main_texture = texture( TEXTURE, UV );
	vec4 output = main_texture;
	
	float og_modulation = 1.0 - tint_factor;
	
	output.rgb = mix( main_texture.rgb * og_modulation, color.rgb * tint_factor, tint_factor );
	output.a *= fade;
	
	COLOR = output;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
