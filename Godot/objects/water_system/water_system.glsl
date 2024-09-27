#[compute]
#version 450

layout(local_size_x = 64) in; // Workgroup size, adjust based on your needs

// Storage buffers for particle data
layout(std430, binding = 0) buffer Positions {
    vec4 positions[]; // Store positions in vec4 for padding
};

layout(std430, binding = 1) buffer Velocities {
    vec4 velocities[]; // Store velocities in vec4 for padding
};

layout(std430, binding = 2) buffer Accelerations {
    vec4 accelerations[];
};

// Uniform variables for simulation constants
uniform float delta_time;
uniform int num_particles;
uniform float particle_radius;
uniform float mass;
uniform float pressure_constant;
uniform float viscosity_constant;
uniform float rest_density;

// Kernel functions for SPH simulation
float poly6_kernel(float r, float h) {
    if (r >= h) return 0.0;
    return (315.0 / (64.0 * 3.14159 * pow(h, 9))) * pow(h * h - r * r, 3);
}

float spiky_gradient(float r, float h) {
    if (r >= h || r == 0.0) return 0.0;
    return -(45.0 / (3.14159 * pow(h, 6))) * pow(h - r, 2);
}

void main() {
    uint id = gl_GlobalInvocationID.x;

    if (id >= num_particles) {
        return;
    }

    vec3 position = positions[id].xyz;
    vec3 velocity = velocities[id].xyz;
    vec3 acceleration = vec3(0.0);

    // Calculate forces based on nearby particles
    for (int i = 0; i < num_particles; i++) {
        if (i == id) continue;

        vec3 other_position = positions[i].xyz;
        vec3 r_vec = position - other_position;
        float r = length(r_vec);

        if (r < particle_radius) {
            float density = mass * poly6_kernel(r, particle_radius);
            float pressure = pressure_constant * (density - rest_density);

            // Pressure force
            vec3 pressure_force = -normalize(r_vec) * mass * pressure * spiky_gradient(r, particle_radius);
            acceleration += pressure_force / density;
        }
    }

    // Update velocity and position based on forces
    velocity += acceleration * delta_time;
    position += velocity * delta_time;

    // Update storage buffers
    positions[id] = vec4(position, 1.0);
    velocities[id] = vec4(velocity, 1.0);
}
