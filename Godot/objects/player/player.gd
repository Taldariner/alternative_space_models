extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5 * 2
const mouse_sensitivity = 0.002

var snowball = preload("res://scenes/snowball.tscn")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += 2 * get_gravity() * delta

	if Input.is_action_just_pressed("ui_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _input(event):
	if event.is_action_pressed("ui_close"):
		get_tree().quit()
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# print("Pivo")
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(70), deg_to_rad(70))
	if event.is_action_pressed("ui_fire"):
		var new_snowball = snowball.instantiate()
		new_snowball.position = $Marker3D.global_position
		get_tree().current_scene.add_child(new_snowball)
		var force = 18
		var up_force = 3.5
		new_snowball.apply_central_impulse($Camera3D.global_transform.basis.z.normalized() * -force + Vector3(0, up_force, 0))
		
