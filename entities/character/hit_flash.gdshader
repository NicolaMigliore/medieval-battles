shader_type spatial;
render_mode blend_mix, unshaded, cull_disabled;

uniform bool use_billboard;
uniform float tilt : hint_range(-3.14159, 3.14159) = 0.0;
varying vec2 local_pos;

void vertex() {
	local_pos = VERTEX.xy;

	if (use_billboard){
		// billboard keeping stretch scaleing
        mat4 mv = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
		mv[0].xyz *= length(MODEL_MATRIX[0].xyz);
		mv[1].xyz *= length(MODEL_MATRIX[1].xyz);
		mv[2].xyz *= length(MODEL_MATRIX[2].xyz);

		// Roll around the view axis (screen-space tilt)
		float s = sin(tilt);
		float c = cos(tilt);
		vec3 right = mv[0].xyz;
		vec3 up = mv[1].xyz;
		mv[0].xyz = right * c + up * s;
		mv[1].xyz = -right * s + up * c;

		MODELVIEW_MATRIX = mv;
	}
}

// Color flash uniforms
uniform sampler2D texture_albedo:source_color,filter_nearest,repeat_disable;
uniform vec3 flash_color:source_color = vec3(1.0);
uniform float intensity:hint_range(0.0, 1.0) = 0.0;
uniform float scissor_threshold : hint_range(0.0, 1.0) = 0.5;

// Outline uniforms
uniform vec3 outline_color: source_color = vec3(1.0,1.0,0.0);
uniform float outline_width : hint_range(0.0, 5.0) = 1.0;
uniform float outline_alpha  : hint_range(0.0, 1.0) = 0.0;

// Glint effect uniforms
uniform bool shield_active = false;
uniform vec3 shimmer_color : source_color = vec3(0.4, 0.7, 1.0);
uniform float shimmer_speed : hint_range(0.0, 5.0) = 1.5;
uniform float shimmer_frequency : hint_range(1.0, 50.0) = 12.0;
uniform float shimmer_strength : hint_range(0.0, 3.0) = 1.0;


void fragment() {
	vec4 tex_color = texture(texture_albedo, UV);
	float alpha = tex_color.a;

	// Default: normal flash rendering
	ALBEDO = mix(tex_color.rgb, flash_color, intensity);
	ALPHA = alpha;
	ALPHA_SCISSOR_THRESHOLD = scissor_threshold;

	// Override with outline where applicable
	if (outline_alpha > 0.0 && alpha < scissor_threshold) {
		vec2 texel = outline_width / vec2(textureSize(texture_albedo, 0));
		float neighbor_alpha = max(
			max(texture(texture_albedo, UV + vec2(texel.x, 0.0)).a, texture(texture_albedo, UV - vec2(texel.x, 0.0)).a),
			max(texture(texture_albedo, UV + vec2(0.0, texel.y)).a, texture(texture_albedo, UV - vec2(0.0, texel.y)).a)
		);
		if (neighbor_alpha >= scissor_threshold) {
			ALBEDO = outline_color;
			ALPHA = mix(ALPHA, 1.0, outline_alpha);
			ALPHA_SCISSOR_THRESHOLD = mix(ALPHA_SCISSOR_THRESHOLD, 0.0, outline_alpha);
		}
	}

	// add glint effect
	if (shield_active && alpha >= scissor_threshold) {
		float diag = (local_pos.x + local_pos.y) * shimmer_frequency - TIME * shimmer_speed;
		float band = pow(clamp(sin(diag), 0.0, 1.0), 4.0);
		ALBEDO += shimmer_color * band * shimmer_strength;
	}
}
