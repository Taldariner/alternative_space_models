extends Node3D

var droplet = preload("res://objects/water_droplet/water_droplet_rigidbody.tscn")
var rng = RandomNumberGenerator.new()
var spawned = 0

@export var camera: Camera3D

func _physics_process(delta: float) -> void:
    if spawned < 2_000:
        var droplet_instance = droplet.instantiate()
        var offset = Vector3(rng.randf_range(-2.0, 2.0), 0.1, rng.randf_range(-1.0, 1.0))
        get_tree().current_scene.add_child(droplet_instance)
        droplet_instance.global_transform.origin = global_transform.origin - offset
        
        var shader_material = droplet_instance.get_node("Mesh").get_surface_override_material(0)
        if shader_material and shader_material is ShaderMaterial:
            shader_material.set("camera_position", camera.global_transform.origin)

        spawned += 1
