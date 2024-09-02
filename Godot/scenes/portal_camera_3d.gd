extends Camera3D

@onready var portal_input: StaticBody3D = $"../../.."
@onready var portal_output: StaticBody3D = $"../../../../StaticBody3D3"
@onready var player: CharacterBody3D = $"../../../../CharacterBody3D"
@onready var player_camera: Camera3D = $"../../../../CharacterBody3D/Camera3D"

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	global_transform.origin = portal_output.global_transform.origin + (player_camera.global_transform.origin - portal_input.global_transform.origin)
	global_transform.basis = player_camera.global_transform.basis
	# print("Viewport : ", get_viewport().get_visible_rect().size)
	# print("Portal   : ", $"..".size)
	print(global_transform.origin)
	$"..".size = player_camera.get_viewport().get_visible_rect().size
	$"..".msaa_3d = player_camera.get_viewport().msaa_3d
	$"..".screen_space_aa = player_camera.get_viewport().screen_space_aa
	$"..".use_taa = player_camera.get_viewport().use_taa
	$"..".use_debanding = player_camera.get_viewport().use_debanding
	$"..".use_occlusion_culling = player_camera.get_viewport().use_occlusion_culling
	$"..".mesh_lod_threshold = player_camera.get_viewport().mesh_lod_threshold
