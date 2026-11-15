extends CharacterBody3D

@export var move_speed: float = 6.0
@export var sprint_multiplier: float = 1.45
@export var acceleration: float = 20.0
@export var gravity: float = 24.0

func _physics_process(delta: float) -> void:
	var input_vector := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_back"
	)

	var direction := Vector3(input_vector.x, 0.0, input_vector.y)
	var current_speed := move_speed

	if Input.is_action_pressed("sprint"):
		current_speed *= sprint_multiplier

	velocity.x = move_toward(velocity.x, direction.x * current_speed, acceleration * delta)
	velocity.z = move_toward(velocity.z, direction.z * current_speed, acceleration * delta)

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	if direction.length_squared() > 0.01:
		look_at(global_position + direction, Vector3.UP)

	move_and_slide()
