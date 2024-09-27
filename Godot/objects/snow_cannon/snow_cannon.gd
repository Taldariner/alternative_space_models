extends MeshInstance3D

@onready var marker_3d: Marker3D = $Marker3D
@onready var timer: Timer = $Timer

var snowball = preload("res://objects/player/snowball.tscn")

func _on_timer_timeout() -> void:
    var new_snowball = snowball.instantiate()
    new_snowball.position = marker_3d.global_position
    get_tree().current_scene.add_child(new_snowball)
    var force = 18
    var up_force = 3.5
    new_snowball.apply_central_impulse(global_transform.basis.z.normalized() * -force + Vector3(0, up_force, 0))
