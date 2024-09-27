extends Node3D

var num_particles: int = 25
var particle_scene: PackedScene = preload("res://objects/water_droplet/water_droplet.tscn")
var particles: Array = []

# For raycasting
@onready var raycast = $RayCast3D

func _ready() -> void:
    spawn_particles()
    for child in get_children():
        if child is FluidParticle:
            particles.append(child)

func spawn_particles() -> void:
    for i in range(num_particles):
        var particle = particle_scene.instantiate()
        var random_position = Vector3(randf() * 0.5 - 0.25, randf() * 0.5 - 0.25, randf() * 0.5 - 0.25) * 4
        
        particle.transform.origin = random_position
        particle.velocity = Vector3(randf() * 0.1 - 0.05, randf() * 0.1 - 0.05, randf() * 0.1 - 0.05) * 10
        add_child(particle)

# Main update function called every frame
func _physics_process(delta: float):
    calculate_density(particles, FluidParticle.PARTICLE_RADIUS)
    calculate_forces(particles, FluidParticle.PARTICLE_RADIUS)
    integrate_particles(particles, delta)

func poly6_kernel(r: float, h: float) -> float:
    if r >= h:
        return 0.0
    return (315.0 / (64.0 * PI * pow(h, 9))) * pow(h * h - r * r, 3)

# Spiky kernel for pressure calculation (gradient)
func spiky_gradient(r: float, h: float) -> float:
    if r >= h or r == 0.0:
        return 0.0
    return -(45.0 / (PI * pow(h, 6))) * pow(h - r, 2)

# Function to calculate density and pressure of each particle
func calculate_density(particles: Array, h: float):
    for p in particles:
        p.density = 0.0
        for other in particles:
            var r = p.get_global_position().distance_to(other.get_global_position())
            p.density += FluidParticle.MASS * poly6_kernel(r, h)
        
        p.density = clamp(p.density, FluidParticle.REST_DENSITY, FluidParticle.REST_DENSITY * 2)
        p.pressure = FluidParticle.PRESSURE_CONSTANT * (p.density - FluidParticle.REST_DENSITY)

const PRESSURE_FORCE_SCALE: float = 0.5

# Function to calculate forces acting on each particle
func calculate_forces(particles: Array, h: float):
    for p in particles:
        var pressure_force: Vector3 = Vector3.ZERO
        var viscosity_force: Vector3 = Vector3.ZERO
        
        for other in particles:
            if p == other:
                continue
            
            var r_vec = p.get_global_position() - other.get_global_position()
            var r = r_vec.length()
            
            if r < h:
                pressure_force += -r_vec.normalized() * FluidParticle.MASS * (p.pressure + other.pressure) / (2.0 * other.density) * spiky_gradient(r, h) * PRESSURE_FORCE_SCALE
            
            if r < h:
                viscosity_force += FluidParticle.VISCOSITY_CONSTANT * FluidParticle.MASS * (other.velocity - p.velocity) / other.density * poly6_kernel(r, h)
        
        p.acceleration = (pressure_force + viscosity_force) / p.density
        p.acceleration += Vector3(0, -9.8, 0)  # Gravity

# Function to update particle positions and velocities based on forces
func integrate_particles(particles: Array, delta: float):
    for p in particles:
        p.velocity += p.acceleration * delta
        var new_position = p.get_global_position() + p.velocity * delta
        
        # Set raycast to current position and update its target
        raycast.set_global_position(p.get_global_position())
        raycast.target_position = new_position
        raycast.force_raycast_update()
        
        if raycast.is_colliding():
            # print("Collision detected at: ", raycast.get_collision_point())
            # print("Collision normal: ", raycast.get_collision_normal())
            var collision_point = raycast.get_collision_point()
            var collision_normal = raycast.get_collision_normal()
            
            # Set particle to collision point and reflect velocity
            p.set_global_position(collision_point)
            p.velocity = reflect_vector(p.velocity, collision_normal) * 0.8  # Reflect with energy loss
            
            # Apply small offset to avoid being stuck
            p.set_global_position(p.get_global_position() + collision_normal.normalized() * FluidParticle.PARTICLE_RADIUS)
        else:
            p.set_global_position(new_position)
        
        # Dampen velocity (friction/energy loss)
        p.velocity *= 0.98

# Reflect velocity on collision
func reflect_vector(velocity: Vector3, normal: Vector3) -> Vector3:
    return velocity - 2.0 * velocity.dot(normal) * normal
