extends StaticBody3D

@export var connected_portal: StaticBody3D
@export var player: CharacterBody3D
@export var player_camera: Camera3D

@onready var self_camera: Camera3D = $PortalSurface/SubViewport/PortalCamera
@onready var self_viewport: SubViewport = $PortalSurface/SubViewport

var previous_player_z = 0
var current_player_z = 0
var tracking_player = false

func _process(delta: float) -> void:
	update_everything()

func _physics_process(delta: float) -> void:
	update_everything()

func update_everything():
	if tracking_player:
		track_player_pass()
	
	self_camera.global_transform.origin = connected_portal.global_transform.origin + (player_camera.global_transform.origin - global_transform.origin)
	self_camera.global_transform.basis = player_camera.global_transform.basis
	
	self_viewport.size = player_camera.get_viewport().get_visible_rect().size
	self_viewport.msaa_3d = player_camera.get_viewport().msaa_3d
	self_viewport.screen_space_aa = player_camera.get_viewport().screen_space_aa
	self_viewport.use_taa = player_camera.get_viewport().use_taa
	self_viewport.use_debanding = player_camera.get_viewport().use_debanding
	self_viewport.use_occlusion_culling = player_camera.get_viewport().use_occlusion_culling
	self_viewport.mesh_lod_threshold = player_camera.get_viewport().mesh_lod_threshold
	
	var world_3d = get_viewport().world_3d
	self_camera.environment = world_3d.environment.duplicate()
	self_camera.environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if (not body.is_class("StaticBody3D") or body.is_class("AnimatableBody3D")) and not body.is_class("CSGShape3D"):
		tracking_player = true
		var local_pos = global_transform.affine_inverse() * body.global_transform.origin
		previous_player_z = _nonzero_sign(local_pos.z)
		current_player_z = _nonzero_sign(local_pos.z)

func _on_area_3d_body_exited(body: Node3D) -> void:
	tracking_player = false

func move_to_other_portal(body: PhysicsBody3D):
	print("moved to other portal")
	# print(body.global_transform.origin)
	var offset = body.global_transform.origin - global_transform.origin
	var camera_offset = player_camera.global_transform.origin - global_transform.origin
	self_camera.global_transform.origin = connected_portal.global_transform.origin + (connected_portal.global_transform.origin + camera_offset - global_transform.origin)
	self_camera.global_transform.basis = player_camera.global_transform.basis
	body.global_transform.origin = connected_portal.global_transform.origin + offset
	# player_camera.global_transform.origin = connected_portal.global_transform.origin + camera_offset
	# print(body.global_transform.origin)
	# print(player.global_transform.origin)
	# print(player_camera.global_transform.origin)
	print(body.name)
	tracking_player = false
	connected_portal.tracking_player = false
	# get_tree().paused = true

func track_player_pass():
	var local_pos = global_transform.affine_inverse() * (player_camera.global_transform.origin)
	current_player_z = _nonzero_sign(local_pos.z)
	if previous_player_z != current_player_z and previous_player_z != 0 and current_player_z != 0:
		print(current_player_z, "<->", previous_player_z)
		print(name, ": Character has crossed the plane!")
		move_to_other_portal(player)
		previous_player_z = current_player_z

func _nonzero_sign(value):
	var s = sign(value)
	if s == 0:
		s = 1
	return s
