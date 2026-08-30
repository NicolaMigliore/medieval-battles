extends Camera3D
class_name  FollowCamera

@export var target:Node3D
@export var offset: Vector3 
@export var smooth_speed: float = 10
@export var rotation_speed: float = 2.0

var yaw: float = 0.0

func _process(delta: float) -> void:
	if not target:
		return

	# Rotate camera with left/right input.
	var camera_input := Input.get_axis("camera_left", "camera_right")
	yaw += camera_input * rotation_speed * delta * -1

	# Rotate the original offset around the character.
	var rotated_offset := offset.rotated(Vector3.UP, yaw)

	var target_pos := target.global_position + rotated_offset
	global_position = global_position.lerp(target_pos, smooth_speed * delta)

	# Keep camera pointed at the character.
	look_at(target.global_position, Vector3.UP)


func get_movement_forward() -> Vector3:
	var rotated_offset := offset.rotated(Vector3.UP, yaw)

	# Direction from camera toward character.
	var forward := -rotated_offset
	forward.y = 0.0

	return forward.normalized()


func get_movement_right() -> Vector3:
	var forward := get_movement_forward()

	return Vector3.UP.cross(forward).normalized()