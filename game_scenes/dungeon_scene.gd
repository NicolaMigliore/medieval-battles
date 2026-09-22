extends GameScene
class_name DungeonScene

@onready var _player = $Player

const ROOM_SIZE: Vector3 = Vector3(16, 3, 16)

# Rooms and Dungeon generation variables
var _random_seed: int
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _room_library: RoomLibrary
var _default_room_library: RoomLibrary = preload("res://assets/room_libraries/crypt.tres")
var _room_scene: PackedScene = preload("res://dungeons/room.tscn")
var _room_dict: Dictionary = {}
var _dungeon_obj: Dungeon

# Room socket props
var _prop_enemy_encounter = preload("res://dungeons/props/enemy_encounter.tscn")


func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_scene_entered(init_props: Dictionary) -> void:
	_room_library = init_props.room_library if init_props.has("room_library") else _default_room_library
	_random_seed = init_props.props.random_seed if init_props.has("random_seed") else randi()
	
	# Generate Dungeon
	_dungeon_obj = Dungeon.new()
	_dungeon_obj.generate(
		Vector2i(9,6), 
		Vector2i(-1,-1),
		3, #5,
		0, #4,
		Vector2i(1,4),
		_random_seed
	)

	# Instantiate rooms
	_instantiate_rooms()

	# Place Player at dungeon entrance
	_place_player_at_entrance()


#region  Init Rooms
func _instantiate_rooms() -> void:
	var room_holder = $RoomHolder
	var room: Room

	# Clear old rooms
	_room_dict = {}
	for child in room_holder.get_children():
		child.queue_free()

	for cell_pos in _dungeon_obj.get_all_room_positions():
		var cell_bitmask: int = _dungeon_obj.get_cell_bitmask(cell_pos)
		if cell_bitmask:
			# Instantiate the room scene
			room = _room_scene.instantiate()
			room.set_bitmask(cell_bitmask)
			room_holder.add_child(room)

			# Position room
			var door_size = 0 #.25
			var room_offset = ROOM_SIZE.x + door_size * 2
			room.global_position = Vector3(cell_pos.x, 0, cell_pos.y) * room_offset

			# Configure room mesh
			var doors_bitmask:int = (cell_bitmask & 0b1111)
			var room_mesh_and_rotation = _room_library.get_room_mesh_and_rotation(doors_bitmask)
			room.set_mesh(room_mesh_and_rotation.mesh, room_mesh_and_rotation.turns)
			
			# Add to room dictionary
			var room_key = "%d_%d" % [cell_pos.x, cell_pos.y]
			_room_dict[room_key] = {
				dungeon_pos = cell_pos,
				room = room
			}

			# TODO: set the room contents or pick a pre-made rooms based on bitmask				
			_populate_room(room)


func _populate_room(room:Room) -> void:
	# spawn enemies
	var room_has_enemies: bool = _dungeon_obj.has_content(room.room_bitmask, Dungeon.Contents.ENEMY)
	if room_has_enemies:
		var enemy_encounters: Array[EnemyEncounter] = []
		var enemy_sockets = room.get_enemy_sockets()
		for i in range(_rng.randi_range(0, enemy_sockets.size())):
			var enemy_encounter: EnemyEncounter = _prop_enemy_encounter.instantiate()
			enemy_encounters.append(enemy_encounter)
			# TODO: Configure encounter with enemy sprites and battle data
		room.spawn_enemy_encounters(enemy_encounters)

	# Set Mission Objective
	var room_has_objective: bool = _dungeon_obj.has_content(room.room_bitmask, Dungeon.Contents.MISSION_OBJECTIVE)
	if room_has_objective:
		# TODO: Implement different objective types
		var boss_encounter: EnemyEncounter = _prop_enemy_encounter.instantiate()
		room.spawn_boss_encounter(boss_encounter)
#endregion


func _place_player_at_entrance() -> void:
	var entrance_dungeon_coords: Vector2i = _dungeon_obj.get_entrance_position()
	var room_key = "%d_%d" % [entrance_dungeon_coords.x, entrance_dungeon_coords.y]
	var room: Room = _room_dict[room_key].room
	var player_spawn_socket = room.get_socket_player_spawn()
	if player_spawn_socket:
		var player_x = player_spawn_socket.position.x
		var player_z = player_spawn_socket.position.z
		_player.position = Vector3(player_x, 0, player_z)
		print("player pos: %s" % _player.position)
	else:
		push_error("No player socket found for room key: %s" % room_key)

