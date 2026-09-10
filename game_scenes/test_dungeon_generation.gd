extends Node3D
class_name TestDungeonGenerator


const WORLD_ANCHOR: Vector3 = Vector3(0,0, 0)
const ROOM_SIZE: Vector3 = Vector3(10, 10, 10)
var _room_scene: PackedScene = preload("res://dungeons/room.tscn")
var room_dict: Dictionary = {}

@export var _dimensions: Vector2i = Vector2i(7,5)
@export var _start: Vector2i = Vector2i(-1,0)
@export var _critical_path_length: int = 13
@export var _branches: int = 3					# TODO: Implement end of branches (https://www.youtube.com/watch?v=-g1eTeq4JYI&t=604s)
@export var _branch_length: Vector2i = Vector2i(1,4)	# store min max in vecotr, i.e., Vector2i(min, max)
var _branch_candidates: Array[Vector2i]

var dungeon: Array

# Info: define the needed bits to bitmask the directions
# more info in this video: https://www.youtube.com/watch?v=-g1eTeq4JYI
enum Doors {
	RIGHT = 1,		#0b0001
	UP = 2,			#0b0010
	LEFT = 4,		#0b0100
	DOWN = 8,		#0b1000
}
# Must be in the sam eorder as the enum Doors
const DIRECTIONS: Array[Vector2i] = [
	Vector2i.RIGHT,
	Vector2i(0,1),
	Vector2i.LEFT,
	Vector2i(0, -1)
]

# Room type definition
enum Contents {
	EMPTY = 0,
	ENTRANCE = 16,
	STARIS = 32,
	ENEMY = 64,
	TREASURE = 128,
	MERCHANT = 256,
	CAMP = 512,
	BOSS = 1024,
	RANDOM = 2048,
	CRITICAL_PATH = 4096
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_init_dungeon()
	_place_entrance()
	_generate_path(_start, _critical_path_length, true)
	_generate_branches()
	_print_dungeon()
	_draw_dungeon()

#region DEBUG
func _unhandled_input(event: InputEvent) -> void:
	var cam: Camera3D = $Camera3D
	var input_dir := Input.get_vector("input_left", "input_right", "input_up", "input_down")
	var speed = 1
	cam.global_position += Vector3(input_dir.x, 0, input_dir.y) * speed
	_sync_labels()
#endregion


func _init_dungeon() -> void:
	dungeon = []
	for x in _dimensions.x:
		dungeon.append([])
		for y in _dimensions.y:
			dungeon[x].append(Contents.EMPTY)


func _place_entrance() -> void:
	if _start.x < 0 or _start.x >= _dimensions.x:
		_start.x = randi_range(0, _dimensions.x - 1)
	if _start.y < 0 or _start.y >= _dimensions.y:
		_start.y = randi_range(0, _dimensions.y - 1)
	
	dungeon[_start.x][_start.y] |= Contents.ENTRANCE		# Assign entrance bit


#region Generate Path
func _generate_path(start_point:Vector2i, length: int, is_critical_path: bool = false) -> bool:
	if length == 0:
		return true
	
	var current:Vector2i = start_point
	var random: int = randi_range(0, 3)
	var direction: Vector2i = DIRECTIONS[random]
	
	# If needed try rotating in the 4 directions util
	for i in 4:
		if (
			current.x + direction.x >= 0 and current.x + direction.x < _dimensions.x and		# is in bounds X
			current.y + direction.y >= 0 and current.y + direction.y < _dimensions.y and		# is in bounds Y
			not dungeon[current.x + direction.x][current.y + direction.y]						# is free cell
			):
			# Set bit to mark needed door for the starting room
			dungeon[current.x][current.y] |= Doors.values()[random]
			# Update current cell
			current += direction
			# Set bit to mark inverse door for the connecting room
			dungeon[current.x][current.y] |= Doors.values()[(random + 2) % 4]
			
			# Set bitmask for critical path
			if is_critical_path:
				dungeon[current.x][current.y] |= Contents.CRITICAL_PATH
			
			# Assign room contents
			match randi_range(0,2):
				1:
					dungeon[current.x][current.y] |= Contents.ENEMY
				2:
					dungeon[current.x][current.y] |= Contents.RANDOM
			
			# Add room to brach candidates
			if length > 1:						# Don't use the last cell of the path as a branch candidate
				_branch_candidates.append(current)
			
			# Continue path or revert changes
			if _generate_path(current, length - 1, is_critical_path):
				return true
			else:
				# If next cell generation failed revert changes
				dungeon[current.x][current.y]=0
				current -= direction
				
				# Remove current from branch candidates
				_branch_candidates.erase(current)
				
				# Remove the added door from the bitmask
				dungeon[current.x][current.y] &= ~Doors.values()[random]
				
		# Change direction rotating the vector
		random += 1
		random %= 4
		direction = DIRECTIONS[random]
	
	return false
#endregion


#region Generate Branches
func _generate_branches() -> void:
	var branches_created: int = 0
	var candidate: Vector2i
	while branches_created < _branches and _branch_candidates.size() > 0:
		candidate = _branch_candidates[randi_range(0, _branch_candidates.size() - 1)]
		# Try to geneerate a branch starting from this candidate
		if _generate_path(candidate, randi_range(_branch_length.x, _branch_length.y)):
			branches_created += 1
		else:
			# If no direction is valid starting from this candidate, then remove it from the candidates
			_branch_candidates.erase(candidate)
#endregion


#region Print and Draw
func _print_dungeon() -> void:
	var dungeon_str = ""
	for y in _dimensions.y:
		for x in _dimensions.x:
			#var cell_str = "\t[%s]" % str(dungeon[x][y]) if dungeon[x][y] else "\t[   ]"
			var tmp_text: String = ("0000%s" % str(dungeon[x][y]))
			var cell_str = "\t[%s]" % tmp_text.substr(tmp_text.length()-4) if dungeon[x][y] else "\t[   ]"
			#var room_key = "%d_%d" % [x, y]
			#var cell_str = "\t[%s]" % room_key if dungeon[x][y] else "\t[   ]"
			dungeon_str = dungeon_str + cell_str
		dungeon_str += "\n"
	
	print("dungeon (%d, %d):\n%s" % [_dimensions.x, _dimensions.y, dungeon_str])


func _draw_dungeon() -> void:
	var room_holder = $RoomHolder
	var room: Node3D
	
	room_dict = {}
	for child in room_holder.get_children():
		child.queue_free()
	
	for y in _dimensions.y:
		for x in _dimensions.x:
			if dungeon[x][y]:
				# Instantiate the room scene
				room = _room_scene.instantiate()
				room_holder.add_child(room)
				var room_key = "%d_%d" % [x, y]
				
				# Position room
				#room.position = WORLD_ANCHOR + Vector3(x, 0, -y) * ROOM_SIZE
				var door_size = 2.5
				var room_offset = ROOM_SIZE.x + door_size + 4
				room.global_position = WORLD_ANCHOR + Vector3(x, 0, y) * room_offset
				print("room pos: %s" % room.position)
				
				# Add label
				var camera: Camera3D = $Camera3D
				var canvas:CanvasLayer = $CanvasLayer
				var lab:Label = Label.new()
				#lab.text = "(%d, %d)" % [x, y]
				var tmp_text: String = ("0000%s" % str(dungeon[x][y]))
				lab.text = tmp_text.substr(tmp_text.length() - 4)
				lab.add_theme_color_override("font_color", Color.BROWN)
				canvas.add_child(lab)
				lab.position = camera.unproject_position(room.global_position)
				
				room_dict[room_key] = {
					room = room,
					label = lab
				}
				
				# Add door scene based on bitmask
				print("values: %s" % str(Doors.values()))
				for i in Doors.size():
					print("i: %s -> door: %s" % [str(Doors.values()[i]), str(dungeon[x][y] & Doors.values()[i])])
					var room_has_door = dungeon[x][y] & Doors.values()[i]
					if room_has_door:
						room.add_door(i)				

				# TODO: set the room contents or pick a premade rooms based on bitmask				
				# Set room color / type
				var is_critical_path = dungeon[x][y] & Contents.CRITICAL_PATH
				var color = Color.AQUAMARINE if is_critical_path else Color.BISQUE
				print("for room value: %s -> color: %s" % [tmp_text, str(color)])
				room.set_room_color(color)

func _sync_labels() -> void:
	var camera: Camera3D = $Camera3D
	for y in _dimensions.y:
		for x in _dimensions.x:
			if dungeon[x][y]:
				# Position room
				var room_key = "%d_%d" % [x, y]
				var room = room_dict[room_key].room
				var label = room_dict[room_key].label
				label.position = camera.unproject_position(room.global_position) + Vector2(-20, 0)

#endregion
