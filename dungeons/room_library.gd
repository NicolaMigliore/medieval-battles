extends Resource
class_name RoomLibrary

@export var room_meshes: Dictionary[int, RoomLibraryEntry]  # canonical bitmask (int) -> Array[PackedScene]

func _rotate_bitmask_90(bits: int) -> int:
	return ((bits << 1) | (bits >> 3)) & 0b1111


func get_room_mesh_and_rotation(bitmask:int ) -> Dictionary:
	# For each door placement configuration
	for entry_key in room_meshes.keys():
		var entry: RoomLibraryEntry = room_meshes[entry_key]
		var rotated = entry.canonical_bitmask
		# For each possible rotation of the room
		for turns in 4:
			# Check if the room has the correct door placement
			if rotated == bitmask:
				var rooms:Array[PackedScene] = entry.variants
				return { "mesh": rooms.pick_random(), "turns": turns}
			rotated = _rotate_bitmask_90(rotated)
	push_error("No matching room mesh for the bitmask %d" % bitmask)
	return {}

