shader_type spatial;
render_mode unshaded;

uniform vec3 circle_color : source_color = vec3(0.2, 0.5, 1.0);  // Light blue color
uniform float circle_radius: hint_range(0.0, 1.0, 0.01) = 0.5;  // Radius of the circle
uniform float softness: hint_range(0.0, 1.0, 0.01) = 0.1;  // Blurry edge softness
uniform float alpha: hint_range(0.0, 1.0, 0.05) = 0.75;  // Opacity of the circle

void fragment() {
    // Calculate the distance from the center of the droplet to create the circle
    vec2 uv = FRAGCOORD.xy / VIEWPORT_SIZE.xy * 2.0 - 1.0;  // Convert to normalized screen coordinates
    float dist_from_center = length(uv);

    // Create a smooth circular edge with a soft blur
    float circle_alpha = smoothstep(circle_radius + softness, circle_radius - softness, dist_from_center);

    // Set the color and alpha (transparency) of the circle
    ALBEDO = circle_color;
    ALPHA = 1.0; // alpha * circle_alpha;
}
