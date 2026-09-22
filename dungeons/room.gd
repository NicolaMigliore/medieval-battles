extends Node3D
class_name Room

var room_bitmask: int
var _mesh_instance: Node3D

var sockets: Dictionary = {}   # socket name -> Array[Dictionary] { position: Vector3, instance: Node3D }

var _door_scene = preload("res://dungeons/door.tscn")


func set_bitmask(bitmask: int) -> void:
	room_bitmask = bitmask

func set_mesh(mesh_scene: PackedScene, rotation_turns: int = 0) -> void:
	if _mesh_instance:
		_mesh_instance.queue_free()
	_mesh_instance = mesh_scene.instantiate()
	add_child(_mesh_instance)
	_mesh_instance.rotation.y = rotation_turns * (PI / 2)

	sockets = _parse_sockets(mesh_scene.resource_path, rotation_turns)


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


#region Prop Sockets
func _parse_sockets(gltf_path: String, rotation_turns: int) -> Dictionary:
	var result: Dictionary = {}
	var file: FileAccess = FileAccess.open(gltf_path, FileAccess.READ)
	if not file:
		push_error("Room: could not open gltf for socket parsing: %s" % gltf_path)
		return result
	
	var data = JSON.parse_string(file.get_as_text())
	if not data:
		push_error("Room: failed to parse gltf JSON: %s" % gltf_path)
		return result

	for node in data.get("nodes", []):
		for point in node.get("extras", {}).get("data", {}).get("points", []):
			var point_name: String = point.get("name","")
			if point_name == "" or point_name == "Origin":
				continue
			var p = point.get("pos", {})
			var local_pos: Vector3 = Vector3(p.get("x", 0), p.get("y", 0), p.get("z", 0))
			local_pos = local_pos.rotated(Vector3.UP, rotation_turns * (PI / 2))
			result.get_or_add(point_name, []).append({"position": to_global(local_pos), "instance": null})

	return result


func get_sockets(socket_name: String) -> Array:
	return sockets.get(socket_name, [])

func get_socket(socket_name: String) -> Dictionary:
	var found: Array = get_sockets(socket_name)
	return found[0] if found.size() > 0 else {"position": global_position, "instance": null}


# func _find_sockets(pattern: String) -> Array:
# 	return _mesh_instance.find_children(pattern, "Node3D", true, false)


func spawn_enemy_encounters(enemy_encounters: Array[EnemyEncounter]) -> void:
	# read prop sockets
	var enemy_sockets:Array = get_enemy_sockets()
	
	if enemy_sockets.size() < enemy_encounters.size():
		push_error("Insufficient enemy sockets for the provided enemy encounters")
		return

	for encounter in enemy_encounters:
		var socket:Dictionary = enemy_sockets.pop_at(randi_range(0, enemy_sockets.size()-1))
		add_child(encounter)
		encounter.global_position = Vector3(socket.position.x, 0, socket.position.z)
		socket.instance = encounter

func spawn_boss_encounter(boss_encounter: EnemyEncounter) -> void:
	var socket: Dictionary = get_socket("socket-boss")
	add_child(boss_encounter)
	boss_encounter.global_position = Vector3(socket.position.x, 0, socket.position.z)
	socket.instance = boss_encounter


func get_socket_player_spawn() -> Dictionary:
	return get_socket("socket-player-spawn")

func get_enemy_sockets():
	return get_sockets("socket-enemy")
	
#endregion
