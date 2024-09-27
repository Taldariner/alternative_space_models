extends Node3D  # Godot 4 update: use Node3D

class_name FluidParticle

# Basic properties for a fluid particle
@export var velocity: Vector3 = Vector3.ZERO
@export var acceleration: Vector3 = Vector3.ZERO
var density: float = 0.0
var pressure: float = 0.0

# Particle constants
const MASS: float = 1.0
const REST_DENSITY: float = 1000.0  # Water's resting density
const PRESSURE_CONSTANT: float = 2000.0  # Tweak this for pressure calculation
const VISCOSITY_CONSTANT: float = 0.1  # Adjust for viscosity effect
const PARTICLE_RADIUS: float = 0.1  # Radius for interaction range
