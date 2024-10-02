extends Node3D

@export var connected_portal: Node3D
@export var player_camera: Camera3D

var tracked_objects = []
var tracked_liquid_particles = []

@onready var self_camera: Camera3D = $PortalSurface/SubViewport/PortalCamera
@onready var self_viewport: SubViewport = $PortalSurface/SubViewport
@onready var water_system: Node3D = $"../WaterSystem01"

func _process(delta: float) -> void:
    update_everything()

func _physics_process(delta: float) -> void:
    update_everything()

func update_everything():
    if tracked_objects.size() > 0:
        track_objects_pass()
    
    self_camera.global_transform.origin = connected_portal.global_transform.origin + (player_camera.global_transform.origin - global_transform.origin)
    self_camera.global_transform.basis = player_camera.global_transform.basis
    
    self_viewport.size = player_camera.get_viewport().get_visible_rect().size
    self_viewport.msaa_3d = player_camera.get_viewport().msaa_3d
    self_viewport.screen_space_aa = player_camera.get_viewport().screen_space_aa
    self_viewport.use_debanding = player_camera.get_viewport().use_debanding
    self_viewport.use_occlusion_culling = player_camera.get_viewport().use_occlusion_culling
    self_viewport.mesh_lod_threshold = player_camera.get_viewport().mesh_lod_threshold
    
    var world_3d = get_viewport().world_3d
    self_camera.environment = world_3d.environment.duplicate()
    self_camera.environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR
    
    for particle in tracked_liquid_particles:
        if particle[1] != null:
            var offset = global_transform.origin - particle[0].global_transform.origin
            particle[1].global_transform.origin = connected_portal.global_transform.origin - offset

func _on_area_3d_body_entered(body: Node3D) -> void:
    if (not body.is_class("StaticBody3D") or body.is_class("AnimatableBody3D")) and not body.is_class("CSGShape3D"):
        var local_pos = global_transform.affine_inverse().origin + body.global_transform.origin
        tracked_objects.append([body, _nonzero_sign(local_pos.z), _nonzero_sign(local_pos.z)])
    if body.is_in_group("liquid_particle"):
        tracked_liquid_particles.append([body, null])

func _on_area_3d_body_exited(body: Node3D) -> void:
    for object in tracked_objects:
        if object[0] == body:
            tracked_objects.erase(object)
    for particle in tracked_liquid_particles:
        if particle[0] == body:
            if particle[1] != null:
                particle[1].queue_free()
                print("deleted duplicate particle!")
            tracked_liquid_particles.erase(particle)

func track_objects_pass():
    for object in tracked_objects:
        var local_pos = global_transform.affine_inverse().origin + object[0].global_transform.origin
        object[2] = _nonzero_sign(local_pos.z)
        if object[1] != object[2]:
            move_to_other_portal(object)
            for particle in tracked_liquid_particles:
                if particle[0] == object[0]:
                    var body_copy = object[0].duplicate()
                    get_tree().get_root().add_child(body_copy)
                    print("added duplicate particle!")
                    particle[1] = body_copy
                    var offset = global_transform.origin - object[0].global_transform.origin
                    particle[1].global_transform.origin = connected_portal.global_transform.origin - offset
        object[1] = object[2]

func move_to_other_portal(object: Array):
    var body = object[0]
    var offset = body.global_transform.origin - global_transform.origin
    if body.name == "Player":
        var camera_offset = player_camera.global_transform.origin - global_transform.origin
        self_camera.global_transform.origin = connected_portal.global_transform.origin + (connected_portal.global_transform.origin + camera_offset - global_transform.origin)
        self_camera.global_transform.basis = player_camera.global_transform.basis
    body.global_transform.origin = connected_portal.global_transform.origin + offset
    
    tracked_objects.erase(object)
    connected_portal.tracked_objects.erase(object)

func _nonzero_sign(value):
    var s = sign(value)
    if s == 0:
        s = 1
    return s
