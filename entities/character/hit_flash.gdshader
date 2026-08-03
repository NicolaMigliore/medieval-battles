shader_type spatial;
render_mode blend_mix, unshaded, cull_disabled;

uniform bool use_billboard;
void vertex() {
	if (use_billboard){
		// billboard keeping stretch scaleing
        mat4 mv = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
		mv[0].xyz *= length(MODEL_MATRIX[0].xyz);
		mv[1].xyz *= length(MODEL_MATRIX[1].xyz);
		mv[2].xyz *= length(MODEL_MATRIX[2].xyz);
		MODELVIEW_MATRIX = mv;
	}
}

uniform sampler2D texture_albedo:source_color,filter_nearest_mipmap;
uniform vec3 flash_color:source_color = vec3(1.0);
uniform float intensity:hint_range(0.0, 1.0) = 0.0;
uniform float scissor_threshold : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec4 tex_color = texture(texture_albedo, UV);
	ALBEDO = mix(tex_color.rgb, flash_color, intensity);
	ALPHA = tex_color.a;
    ALPHA_SCISSOR_THRESHOLD = scissor_threshold;
}