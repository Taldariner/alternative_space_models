extends Node3D

var droplet = preload("res://objects/droplet.tscn")
var rng = RandomNumberGenerator.new()
var spawned = 0

func _physics_process(delta: float) -> void:
	if spawned < 1_000:
		var droplet_instance = droplet.instantiate()
		var offset = Vector3(rng.randf_range(-0.1, 0.1), 0.1, rng.randf_range(-0.1, 0.1))
		droplet_instance.global_transform.origin = global_transform.origin - offset
		get_tree().current_scene.add_child(droplet_instance)
		spawned += 1
