extends Node3D

var num_particles: int = 1000
var particle_radius: float = 0.1
var delta_time: float = 0.016

var particle_positions: PackedVector3Array
var particle_velocities: PackedVector3Array

# Compute shader pipeline and buffers
var compute_pipeline: RDComputePipeline
var position_buffer: RDShaderStorageBuffer
var velocity_buffer: RDShaderStorageBuffer
var acceleration_buffer: RDShaderStorageBuffer

func _ready():
    # Initialize compute shader pipeline
    var compute_shader = load("res://objects/water_system/fluid_compute_shader.glsl")
    compute_pipeline = RDComputePipeline.new()
    compute_pipeline.compute_shader = compute_shader

    # Initialize particle data
    initialize_particle_buffers()

    # Create and upload buffers to GPU
    position_buffer = RDShaderStorageBuffer.new()
    velocity_buffer = RDShaderStorageBuffer.new()
    acceleration_buffer = RDShaderStorageBuffer.new()

    position_buffer.create(particle_positions.size() * 12)  # 3 floats per position
    velocity_buffer.create(particle_velocities.size() * 12)
    acceleration_buffer.create(particle_positions.size() * 12)

    position_buffer.update(particle_positions)
    velocity_buffer.update(particle_velocities)

    # Set buffers for the pipeline
    compute_pipeline.set_storage_buffer(0, position_buffer)
    compute_pipeline.set_storage_buffer(1, velocity_buffer)
    compute_pipeline.set_storage_buffer(2, acceleration_buffer)

    # Set uniforms
    compute_pipeline.set_uniform("delta_time", delta_time)
    compute_pipeline.set_uniform("num_particles", num_particles)
    compute_pipeline.set_uniform("particle_radius", particle_radius)
    compute_pipeline.set_uniform("mass", 1.0)
    compute_pipeline.set_uniform("pressure_constant", 2000.0)
    compute_pipeline.set_uniform("viscosity_constant", 0.1)
    compute_pipeline.set_uniform("rest_density", 1000.0)

    # Set to run the compute shader on the next physics tick
    set_physics_process(true)

func initialize_particle_buffers():
    particle_positions = PackedVector3Array()
    particle_velocities = PackedVector3Array()

    # Initialize positions and velocities
    for i in range(num_particles):
        particle_positions.append(Vector3(randf() * 10.0 - 5.0, randf() * 10.0 - 5.0, randf() * 10.0 - 5.0))
        particle_velocities.append(Vector3.ZERO)

func _physics_process(delta: float):
    # Update delta time uniform
    compute_pipeline.set_uniform("delta_time", delta)

    # Dispatch the compute shader to update particles
    compute_pipeline.dispatch(num_particles, 1, 1)

    # Optionally, read back positions from GPU and update visuals
    particle_positions = position_buffer.read_back()

    # Update your particle rendering (e.g., MultiMeshInstance3D) with new positions
    for i in range(num_particles):
        var position = particle_positions[i]
        $MultiMeshInstance3D.multimesh.set_instance_transform(i, Transform().translated(position))
