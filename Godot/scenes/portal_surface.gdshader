shader_type spatial;
render_mode unshaded, cull_disabled;
uniform sampler2D texture_albedo : source_color;
uniform float blue_tint_strength : hint_range(0.0, 1.0) = 0.5; // Strength of the blue tint

void fragment() {
    vec2 base_uv = SCREEN_UV;
    vec4 albedo_tex = texture(texture_albedo, base_uv);

    // Apply blue tint
    vec3 blue_tint = vec3(0.0, 0.0, 1.0); // Pure blue color
    vec3 tinted_color = mix(albedo_tex.rgb, blue_tint, blue_tint_strength); // Blend the texture with the blue tint

    ALBEDO = tinted_color;
}