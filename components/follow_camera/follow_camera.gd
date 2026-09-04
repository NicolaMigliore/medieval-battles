extends Camera3D
class_name  FollowCamera

@export var target:Node3D
@export var offset: Vector3 
@export var smooth_speed: float = 10
@export var rotation_speed: float = 2.0
@export var snap_angle_degrees: float = 45.0

enum Mode { FOLLOW, FOLLOW_FIXED_ROTATION, DIALOGUE_FOCUS }
@export var mode = Mode.FOLLOW
var previous_mode = null

var yaw: float = 0.0
var target_yaw: float = 0.0

var dialogue_actionable:Actionable 

func _process(delta: float) -> void:
	rotation = Vector3(0.0, 45.0, 0.0)
	if not target:
		return

	if mode == Mode.FOLLOW:
		# Rotate camera with left/right input.
		var camera_input := Input.get_axis("camera_left", "camera_right")
		yaw += camera_input * rotation_speed * delta * -1

		# Rotate the original offset around the character.
		var rotated_offset := offset.rotated(Vector3.UP, yaw)

		var target_pos := target.global_position + rotated_offset
		global_position = global_position.lerp(target_pos, smooth_speed * delta)

		# Keep camera pointed at the character.
		look_at(target.global_position, Vector3.UP)
	elif mode == Mode.FOLLOW_FIXED_ROTATION:
		# Snap the target yaw by 45° on each discrete press (not held/continuous).
		if Input.is_action_just_pressed("camera_left"):
			target_yaw += deg_to_rad(snap_angle_degrees)
		if Input.is_action_just_pressed("camera_right"):
			target_yaw -= deg_to_rad(snap_angle_degrees)

		# Glide the actual yaw toward the snapped target.
		yaw = lerp_angle(yaw, target_yaw, rotation_speed * delta)

		# Rotate the original offset around the character.
		var rotated_offset := offset.rotated(Vector3.UP, yaw)

		var target_pos := target.global_position + rotated_offset
		global_position = global_position.lerp(target_pos, smooth_speed * delta)

		# Keep camera pointed at the character.
		look_at(target.global_position, Vector3.UP)
	elif mode == Mode.DIALOGUE_FOCUS and dialogue_actionable:
		var target_pos_global = target.global_position
		var actionable_pos_global = dialogue_actionable.global_position
		var focus_point: Vector3 = (actionable_pos_global + target_pos_global) / 2

		var dialogue_zoom = 0.75
		var focus_offset: Vector3 = offset.rotated(Vector3.UP, yaw).normalized() * dialogue_zoom
		var target_pos = focus_point + focus_offset
		global_position = global_position.lerp(target_pos, smooth_speed * delta)

		look_at(focus_point, Vector3.UP)



func get_movement_forward() -> Vector3:
	var rotated_offset := offset.rotated(Vector3.UP, yaw)

	# Direction from camera toward character.
	var forward := -rotated_offset
	forward.y = 0.0

	return forward.normalized()


func get_movement_right() -> Vector3:
	var forward := get_movement_forward()

	return forward.cross(Vector3.UP).normalized()


func start_dialog_focus(actionable: Actionable) -> void:
	previous_mode = mode
	dialogue_actionable = actionable
	mode = Mode.DIALOGUE_FOCUS

func end_dialogue_focus() -> void:
	mode = previous_mode
	dialogue_actionable = null
