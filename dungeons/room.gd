extends Node3D
class_name Room

var _mesh_instance: Node3D

var _door_scene = preload("res://dungeons/door.tscn")


func set_mesh(mesh_scene: PackedScene, rotation_turns: int = 0) -> void:
	if _mesh_instance:
		_mesh_instance.queue_free()
	_mesh_instance = mesh_scene.instantiate()
	add_child(_mesh_instance)
	# _mesh_instance.rotate(Vector3.UP, rotation_turns * (PI / 2))
	_mesh_instance.rotation.y = rotation_turns * (PI / 2)


func add_door(direction_idx: int) -> void:
	var direction: Vector2i = Dungeon.DIRECTIONS[direction_idx]
	var door = _door_scene.instantiate()
	add_child(door)
	var room_size:float = 4
	var door_size:float = 1
	var door_offset = room_size/2 + door_size/2
	door.global_position = global_position + Vector3(direction.x, 0, direction.y) * door_offset


func set_room_color(color: Color) -> void:
	var box: CSGBox3D = $CSGBox3D
	box.material.albedo_color = color
