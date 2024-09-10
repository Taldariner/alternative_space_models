shader_type spatial;

uniform sampler2D water_normal_noise;
uniform float uv_scale: hint_range(0.0, 10.0, 0.25) = 1.0;
uniform vec3 water_color : source_color;
uniform float time_scale: hint_range(0.0, 10.0, 0.25) = 1.0;

uniform float alpha            :hint_range(0.0, 1.0, 0.05) = 0.75;
uniform float normal_scale    : hint_range(0.0, 1.0, 0.1) = 0.5;
uniform float roughness_scale : hint_range(0.0, 1.0, 0.05) = 0.25;

uniform sampler2D sun_highlights;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable;  // Screen texture for refraction

uniform float color_ratio : hint_range(0.0, 1.0, 0.1) = 0.5;
uniform float refraction_strength: hint_range(0.0, 1.0, 0.05) = 0.05;  // Strength of the refraction effect

uniform vec2 aberration_r;
uniform vec2 aberration_g;
uniform vec2 aberration_b;

uniform float highlights_time_scale = 1.0;
uniform float wave_amplitude : hint_range(0.0, 2.0) = 0.1;  // Amplitude of the wave
uniform float wave_frequency : hint_range(0.0, 10.0) = 1.0;  // Frequency of the wave

varying vec3 world_pos;  // Store world position

vec3 soft_light(vec3 base, vec3 blend) {
    vec3 limit = step(0.5, blend);
    return mix(2.0 * base * blend + base * base * (1.0 - 2.0 * blend), 
               sqrt(base) * (2.0 * blend - 1.0) + (2.0 * base) * (1.0 - blend), limit);
}

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;  // Get world position

    // Use UV coordinates for symmetrical wave movement
    float wave1 = sin(UV.x * wave_frequency * PI * 2.0 + TIME * time_scale) * wave_amplitude;
    float wave2 = cos(UV.y * wave_frequency * PI * 2.0 + TIME * time_scale) * wave_amplitude;

    // Combine the waves for a more complex pattern
    VERTEX.y += wave1 + wave2;
}

void fragment() {
    vec2 _uv = UV * uv_scale;  // Use UV space for seamless tiling across meshes

    // Use the time-based offsets for dynamic water effect
    _uv.x += sin(TIME * time_scale + (_uv.x + _uv.y) * 25.0) * 0.01;
    _uv.y += cos(TIME * time_scale + (_uv.x - _uv.y) * 25.0) * 0.01;

    // Calculate the normal map based on the water noise texture
    vec3 normal_map = texture(water_normal_noise, _uv).rgb * 2.0 - 1.0;  // Convert from [0,1] to [-1,1]
    normal_map.xy *= normal_scale;

    // Apply refraction based on the normal map distortion
    vec2 screen_uv = SCREEN_UV;
    screen_uv += normal_map.xy * refraction_strength;  // Distort the screen UV based on the normals

    // Sample the screen texture to create the refraction effect
    vec3 refraction_color = texture(screen_texture, screen_uv).rgb;

    // Introduce sun highlights based on the distorted UV
    float r = texture(sun_highlights, _uv + aberration_r + TIME * highlights_time_scale).r;
    float g = texture(sun_highlights, _uv + aberration_g + TIME * highlights_time_scale).g;
    float b = texture(sun_highlights, _uv + aberration_b + TIME * highlights_time_scale).b;
    vec3 highlight_color = vec3(r, g, b);

    // Blending the highlights and water color
    vec3 blended = soft_light(refraction_color, highlight_color);

    // Final color blending with water color
    ALBEDO = mix(blended, water_color, color_ratio);
    ALPHA = alpha;
    // Normal map for lighting
    NORMAL_MAP = normal_map;
    NORMAL *= normal_scale;

    // Control roughness
    ROUGHNESS = roughness_scale;
}
