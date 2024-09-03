extends StaticBody3D

@export var connected_portal: StaticBody3D
@export var player: CharacterBody3D
@export var player_camera: Camera3D

@onready var self_camera: Camera3D = $PortalSurface/SubViewport/PortalCamera
@onready var self_viewport: SubViewport = $PortalSurface/SubViewport

func _ready() -> void:
	pass

func _process(delta: float) -> void:
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
