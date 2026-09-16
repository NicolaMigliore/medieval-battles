extends Node
class_name RoomLibrary

# Canonical door bitmask to room mesh dictionary
const ROOM_MESHES : Dictionary = {
	8: [
			preload("res://assets/meshes/dungeon_plains/room-plains-s.glb"),
			preload("res://assets/meshes/dungeon_plains/room-plains-s-1.glb")
		], 
	9: [preload("res://assets/meshes/dungeon_plains/room-plains-se.glb")], 
	10: [
			preload("res://assets/meshes/dungeon_plains/room-plains-sn.glb"),
			preload("res://assets/meshes/dungeon_plains/room-plains-sn-2.glb"),
			preload("res://assets/meshes/dungeon_plains/room-plains-sn-3.glb")
		], 
	13: [preload("res://assets/meshes/dungeon_plains/room-plains-swe.glb")],
	15: [preload("res://assets/meshes/dungeon_plains/room-plains-swne.glb")],
}


func _rotate_bitmask_90(bits: int) -> int:
	return ((bits << 1) | (bits >> 3)) & 0b1111


func get_room_mesh_and_rotation(bitmask:int ) -> Dictionary:
	# For each door placement configuration
	for canonical in ROOM_MESHES:
		var rotated = canonical
		# For each possible rotation of the room
		for turns in 4:
			# Check if the room has the correct door placement
			if rotated == bitmask:
				var rooms:Array = ROOM_MESHES[canonical]
				return { "mesh": rooms.pick_random(), "turns": turns}
			rotated = _rotate_bitmask_90(rotated)
	push_error("No matching room mesh for the bitmask %d" % bitmask)
	return {}