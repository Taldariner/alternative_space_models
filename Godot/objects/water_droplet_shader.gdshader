shader_type spatial;
render_mode blend_add;

uniform float uv_scale: hint_range(0.0, 10.0, 0.25) = 1.0;
uniform vec3 water_color : source_color;
uniform float time_scale: hint_range(0.0, 10.0, 0.25) = 1.0;

uniform float alpha: hint_range(0.0, 1.0, 0.05) = 0.75;
uniform float roughness_scale: hint_range(0.0, 1.0, 0.05) = 0.25;

uniform sampler2D sun_highlights;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable;  // Screen texture for refraction

uniform float color_ratio: hint_range(0.0, 1.0, 0.1) = 0.5;
uniform float refraction_strength: hint_range(0.0, 1.0, 0.05) = 0.05;  // Strength of the refraction effect

uniform vec2 aberration_r;
uniform vec2 aberration_g;
uniform vec2 aberration_b;

uniform float highlights_time_scale = 1.0;
uniform float sphere_radius = 0.5; // Set the radius of the droplet for overlap calculation
uniform float soft_intersection_factor = 0.2;  // Controls blending at overlaps

varying vec3 world_pos;  // Store world position

vec3 soft_light(vec3 base, vec3 blend) {
    vec3 limit = step(0.5, blend);
    return mix(2.0 * base * blend + base * base * (1.0 - 2.0 * blend), 
               sqrt(base) * (2.0 * blend - 1.0) + (2.0 * base) * (1.0 - blend), limit);
}

void fragment() {
    vec2 _uv = UV * uv_scale;  // Use UV space for seamless tiling across droplets

    // Time-based offsets for dynamic water effect
    _uv.x += sin(TIME * time_scale + (_uv.x + _uv.y) * 25.0) * 0.01;
    _uv.y += cos(TIME * time_scale + (_uv.x - _uv.y) * 25.0) * 0.01;

    // Calculate the distance from the center of the droplet to create blending at the edges
    float distance_from_center = length(world_pos.xy);  // Droplet position in 2D space

    // Smooth blending at intersections (soft union effect)
    float blend_factor = smoothstep(sphere_radius * (1.0 - soft_intersection_factor), sphere_radius, distance_from_center);

    // Modify alpha and color blending to avoid dark spots at intersections
    float intersection_blend = pow(1.0 - blend_factor, soft_intersection_factor);  // Makes the overlap regions less pronounced

    // Apply refraction based on the normal map distortion
    vec2 screen_uv = SCREEN_UV;

    // Sample the screen texture to create the refraction effect
    vec3 refraction_color = texture(screen_texture, screen_uv).rgb;

    // Introduce sun highlights based on the distorted UV
    float r = texture(sun_highlights, _uv + aberration_r + TIME * highlights_time_scale).r;
    float g = texture(sun_highlights, _uv + aberration_g + TIME * highlights_time_scale).g;
    float b = texture(sun_highlights, _uv + aberration_b + TIME * highlights_time_scale).b;
    // vec3 highlight_color = vec3(r, g, b);

    // Blending the highlights and water color
    // vec3 blended = soft_light(refraction_color, highlight_color);

    // Final color blending with water color
    ALBEDO = mix(refraction_color, water_color, color_ratio);
    
    // Smooth alpha blending at intersections
    ALPHA = mix(alpha, alpha * intersection_blend, blend_factor);

    // Control roughness
    ROUGHNESS = roughness_scale * intersection_blend;
}
