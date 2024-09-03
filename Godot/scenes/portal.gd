extends StaticBody3D

@export var connected_portal: StaticBody3D
@export var player: CharacterBody3D
@export var player_camera: Camera3D

@onready var self_camera: Camera3D = $PortalSurface/SubViewport/PortalCamera
@onready var self_viewport: SubViewport = $PortalSurface/SubViewport

# var _tracked_phys_bodies = []
# const MOVE_WAS_TELEPORT_THRESHOLD = 5.1
var previous_player_z = 0
var current_player_z = 0
var tracking_player = false

## only solution I found was to lower near cull plane on camera
@export var enable_camera_near_plane_fix: bool = true
const CAM_NEAR_NEEDED_TO_PREVENT_GLITCH = 0.001

func _ready() -> void:
	print(get_tree().root.use_occlusion_culling)
	pass

func _physics_process(delta: float) -> void:
	
	if tracking_player:
		_get_bodies_which_passed_through_this_frame()
		# 	_move_to_other_portal(body)
	
	self_camera.global_transform.origin = connected_portal.global_transform.origin + (player_camera.global_transform.origin - global_transform.origin)
	self_camera.global_transform.basis = player_camera.global_transform.basis
	# print("Viewport : ", get_viewport().get_visible_rect().size)
	# print("Portal   : ", $"..".size)
	# print(global_transform.origin)
	
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
		# if _check_shapecast_collision(body):
		print("+")
		# _tracked_phys_bodies.append(body)
		tracking_player = true
		var local_pos = global_transform.affine_inverse() * body.global_transform.origin
		previous_player_z = _nonzero_sign(local_pos.z)
		current_player_z = _nonzero_sign(local_pos.z)

func _on_area_3d_body_exited(body: Node3D) -> void:
	# if not _check_shapecast_collision(body) or $CollisionShape3D.disabled:
	print("-")
	# _tracked_phys_bodies.remove_at(0)
	tracking_player = false

func _move_to_other_portal(body: PhysicsBody3D):
	print("moved to other portal")
	print(body.global_transform.origin)
	var offset = body.global_transform.origin - global_transform.origin
	body.global_transform.origin = connected_portal.global_transform.origin + offset
	print(body.global_transform.origin)
	print(body.name)
	# _tracked_phys_bodies.remove_at(0)
	tracking_player = false
	# connected_portal._tracked_phys_bodies.append(body)
	connected_portal.tracking_player = false
	# get_tree().paused = true

func _get_bodies_which_passed_through_this_frame():
	# var bodies_that_passed_through = []
	# if len(_tracked_phys_bodies) > 0:
	# 	print(_tracked_phys_bodies)
	for tracked_body in [player]:
		var local_pos = global_transform.affine_inverse() * (player.global_transform.origin)
		current_player_z = _nonzero_sign(local_pos.z)
		
		if _nonzero_sign(previous_player_z) != _nonzero_sign(current_player_z):
			print(current_player_z, "<->", previous_player_z)
			print(name, ": Character has crossed the plane!")
			_move_to_other_portal(player)
			previous_player_z = current_player_z

'''
# Function to teleport the character to the linked portal
func teleport_character(character: CharacterBody3D) -> void:
	if connected_portal:
		# Get the offset relative to the portal's entry point
		var offset = character.global_transform.origin - global_transform.origin
		
		# Teleport the character to the corresponding position relative to the exit portal
		character.global_transform.origin = connected_portal.global_transform.origin + offset

		# Optional: Adjust character orientation to match the portal's exit orientation
		var entry_rotation = global_transform.basis
		var exit_rotation = connected_portal.global_transform.basis
		character.global_transform.basis = exit_rotation * entry_rotation.inverse() * character.global_transform.basis
'''

func _nonzero_sign(value):
	var s = sign(value)
	# if s == 0:
	#	s = 1
	return s
