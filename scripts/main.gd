extends Node3D

const PLAYER_SCRIPT = preload("res://scripts/player.gd")

func _ready() -> void:
	_setup_input_actions()
	_build_world()
	_build_pitch()
	_build_player()
	_build_ball()
	_build_camera()
	_build_touch_controls()


func _setup_input_actions() -> void:
	_add_key_action("move_forward", KEY_W)
	_add_key_action("move_forward", KEY_UP)
	_add_key_action("move_back", KEY_S)
	_add_key_action("move_back", KEY_DOWN)
	_add_key_action("move_left", KEY_A)
	_add_key_action("move_left", KEY_LEFT)
	_add_key_action("move_right", KEY_D)
	_add_key_action("move_right", KEY_RIGHT)
	_add_key_action("sprint", KEY_SHIFT)


func _add_key_action(action_name: String, keycode: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

	var event := InputEventKey.new()
	event.physical_keycode = keycode
	InputMap.action_add_event(action_name, event)


func _build_world() -> void:
	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.055, 0.09, 0.12)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.72, 0.78, 0.82)
	environment.ambient_light_energy = 0.65
	world_environment.environment = environment
	add_child(world_environment)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52.0, -25.0, 0.0)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	add_child(sun)


func _build_pitch() -> void:
	var floor_body := StaticBody3D.new()
	floor_body.name = "Pitch"
	floor_body.position.y = -0.15
	add_child(floor_body)

	var floor_shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = Vector3(30.0, 0.3, 20.0)
	floor_shape.shape = box_shape
	floor_body.add_child(floor_shape)

	var floor_mesh := MeshInstance3D.new()
	var plane := BoxMesh.new()
	plane.size = Vector3(30.0, 0.3, 20.0)
	floor_mesh.mesh = plane
	floor_mesh.material_override = _make_material(Color(0.08, 0.38, 0.19))
	floor_body.add_child(floor_mesh)

	var line_color := Color(0.88, 0.94, 0.88)
	_add_box(floor_body, "TouchlineNorth", Vector3(0, 0.17, -9.75), Vector3(29.5, 0.025, 0.08), line_color)
	_add_box(floor_body, "TouchlineSouth", Vector3(0, 0.17, 9.75), Vector3(29.5, 0.025, 0.08), line_color)
	_add_box(floor_body, "GoalLineWest", Vector3(-14.75, 0.17, 0), Vector3(0.08, 0.025, 19.5), line_color)
	_add_box(floor_body, "GoalLineEast", Vector3(14.75, 0.17, 0), Vector3(0.08, 0.025, 19.5), line_color)
	_add_box(floor_body, "HalfwayLine", Vector3(0, 0.17, 0), Vector3(0.07, 0.025, 19.5), line_color)

	_add_goal(-1.0)
	_add_goal(1.0)


func _add_goal(side: float) -> void:
	var x := side * 14.95
	var post_material := _make_material(Color(0.92, 0.94, 0.96))
	_add_box(self, "GoalPost", Vector3(x, 1.1, -2.0), Vector3(0.16, 2.2, 0.16), Color(0.92, 0.94, 0.96), post_material)
	_add_box(self, "GoalPost", Vector3(x, 1.1, 2.0), Vector3(0.16, 2.2, 0.16), Color(0.92, 0.94, 0.96), post_material)
	_add_box(self, "GoalCrossbar", Vector3(x, 2.2, 0), Vector3(0.16, 0.16, 4.0), Color(0.92, 0.94, 0.96), post_material)


func _build_player() -> void:
	var player := CharacterBody3D.new()
	player.name = "Player"
	player.position = Vector3(-4.0, 0.95, 0.0)
	player.set_script(PLAYER_SCRIPT)
	player.floor_snap_length = 0.2
	add_child(player)

	var collision := CollisionShape3D.new()
	var capsule_shape := CapsuleShape3D.new()
	capsule_shape.radius = 0.42
	capsule_shape.height = 1.9
	collision.shape = capsule_shape
	player.add_child(collision)

	var visual := MeshInstance3D.new()
	var capsule_mesh := CapsuleMesh.new()
	capsule_mesh.radius = 0.42
	capsule_mesh.height = 1.9
	visual.mesh = capsule_mesh
	visual.material_override = _make_material(Color(0.12, 0.35, 0.95))
	player.add_child(visual)


func _build_ball() -> void:
	var ball := RigidBody3D.new()
	ball.name = "Ball"
	ball.position = Vector3(0.0, 0.42, -1.0)
	ball.mass = 0.45
	ball.linear_damp = 0.45
	ball.angular_damp = 0.5
	add_child(ball)

	var collision := CollisionShape3D.new()
	var sphere_shape := SphereShape3D.new()
	sphere_shape.radius = 0.34
	collision.shape = sphere_shape
	ball.add_child(collision)

	var visual := MeshInstance3D.new()
	var sphere_mesh := SphereMesh.new()
	sphere_mesh.radius = 0.34
	sphere_mesh.height = 0.68
	visual.mesh = sphere_mesh
	visual.material_override = _make_material(Color(0.95, 0.95, 0.9))
	ball.add_child(visual)


func _build_camera() -> void:
	var camera := Camera3D.new()
	camera.name = "MatchCamera"
	camera.position = Vector3(0.0, 22.0, 20.0)
	camera.fov = 58.0
	camera.current = true
	add_child(camera)
	camera.look_at(Vector3.ZERO, Vector3.UP)


func _build_touch_controls() -> void:
	var layer := CanvasLayer.new()
	layer.name = "TouchControls"
	add_child(layer)

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(root)

	_make_touch_button(root, "↑", "move_forward", 24, -222, 92, -154, false)
	_make_touch_button(root, "←", "move_left", 0, -150, 68, -82, false)
	_make_touch_button(root, "↓", "move_back", 24, -78, 92, -10, false)
	_make_touch_button(root, "→", "move_right", 96, -150, 164, -82, false)
	_make_touch_button(root, "SPRINT", "sprint", -154, -104, -24, -38, true)


func _make_touch_button(
	parent: Control,
	label: String,
	action_name: String,
	left: float,
	top: float,
	right: float,
	bottom: float,
	anchor_right: bool
) -> void:
	var button := Button.new()
	button.text = label
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(68, 68)
	button.add_theme_font_size_override("font_size", 24 if label != "SPRINT" else 15)

	if anchor_right:
		button.anchor_left = 1.0
		button.anchor_right = 1.0
	else:
		button.anchor_left = 0.0
		button.anchor_right = 0.0

	button.anchor_top = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = left
	button.offset_top = top
	button.offset_right = right
	button.offset_bottom = bottom

	button.button_down.connect(_press_action.bind(action_name))
	button.button_up.connect(_release_action.bind(action_name))
	parent.add_child(button)


func _press_action(action_name: String) -> void:
	Input.action_press(action_name)


func _release_action(action_name: String) -> void:
	Input.action_release(action_name)


func _add_box(
	parent: Node3D,
	node_name: String,
	position_value: Vector3,
	size_value: Vector3,
	color_value: Color,
	material_override: Material = null
) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	mesh_instance.position = position_value
	var box_mesh := BoxMesh.new()
	box_mesh.size = size_value
	mesh_instance.mesh = box_mesh
	if material_override != null:
		mesh_instance.material_override = material_override
	else:
		mesh_instance.material_override = _make_material(color_value)
	parent.add_child(mesh_instance)


func _make_material(color_value: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color_value
	material.roughness = 0.88
	return material
