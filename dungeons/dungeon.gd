extends RefCounted
class_name Dungeon

# Info: define the needed bits to bitmask the directions
# more info in this video: https://www.youtube.com/watch?v=-g1eTeq4JYI
enum Doors {
	RIGHT = 1,		#0b0001
	UP = 2,			#0b0010
	LEFT = 4,		#0b0100
	DOWN = 8,		#0b1000
}
# Room type definition
enum Contents {
	EMPTY = 0,
	ENTRANCE = 16,
	STAIRS = 32,
	MISSION_OBJECTIVE = 64,
	TREASURE = 128,
	MERCHANT = 256,
	BRANCH_END = 512,
	# BOSS = 1024,
	# RANDOM = 2048,
	CRITICAL_PATH = 4096
}
# Must be in the same order as the enum Doors
const DIRECTIONS: Array[Vector2i] = [
	Vector2i.RIGHT,
	Vector2i(0,1),
	Vector2i.LEFT,
	Vector2i(0, -1)
]


var _dimensions: Vector2i = Vector2i(7,5)
var _start: Vector2i = Vector2i(-1,0)
var _critical_path_length: int = 13
var _branches: int = 3					# TODO: Implement end of branches (https://www.youtube.com/watch?v=-g1eTeq4JYI&t=604s)
var _branch_length: Vector2i = Vector2i(1,4)	# store min max in vector, i.e., Vector2i(min, max)
var _branch_candidates: Array[Vector2i]

var _grid:Array			# array of arrays containing the generated dungeon data 

#region Generation

# Initialize dungeon 
func generate(
	dimensions: Vector2i = Vector2i(7,5), 
	start: Vector2i = Vector2i(-1,-1),
	critical_path_length: int = 13,
	branches: int = 3,
	branch_length: Vector2i = Vector2i(1,4)
) -> void:
	_dimensions = dimensions
	_start = start
	_critical_path_length = critical_path_length
	_branches = branches
	_branch_length = branch_length

	_init_grid()
	_place_entrance()
	_generate_path(_start, _critical_path_length, true)
	_generate_branches()


func _init_grid() -> void:
	_grid = []
	_branch_candidates = []
	for x in _dimensions.x:
		_grid.append([])
		for y in _dimensions.y:
			_grid[x].append(Contents.EMPTY)


func _place_entrance() -> void:
	if _start.x < 0 or _start.x >= _dimensions.x:
		_start.x = randi_range(0, _dimensions.x - 1)
	if _start.y < 0 or _start.y >= _dimensions.y:
		_start.y = randi_range(0, _dimensions.y - 1)
	
	_grid[_start.x][_start.y] |= Contents.ENTRANCE		# Assign entrance bit


func _generate_path(start_point:Vector2i, length: int, mark_critical_path: bool = false) -> bool:
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
			not _grid[current.x + direction.x][current.y + direction.y]							# is free cell
			):
			# Set bit to mark needed door for the starting room
			_grid[current.x][current.y] |= Doors.values()[random]
			# Update current cell
			current += direction
			# Set bit to mark inverse door for the connecting room
			_grid[current.x][current.y] |= Doors.values()[(random + 2) % 4]
			
			# Set bitmask for critical path
			if mark_critical_path:
				_grid[current.x][current.y] |= Contents.CRITICAL_PATH
				if length == 1:
					_grid[current.x][current.y] |= Contents.MISSION_OBJECTIVE
			
			# Assign room contents
			match randi_range(0,2):
				1:
					_grid[current.x][current.y] |= Contents.TREASURE
				2:
					_grid[current.x][current.y] |= Contents.MERCHANT
			
			# Add room to brach candidates
			if length > 1:				# Don't use the last cell of the path as a branch candidate
				_branch_candidates.append(current)
			elif length == 1:
				_grid[current.x][current.y] |= Contents.BRANCH_END
			
			# Continue path or revert changes
			if _generate_path(current, length - 1, mark_critical_path):
				return true
			else:
				# If next cell generation failed revert changes
				_grid[current.x][current.y]=0
				current -= direction
				
				# Remove current from branch candidates
				_branch_candidates.erase(current)
				
				# Remove the added door from the bitmask
				_grid[current.x][current.y] &= ~Doors.values()[random]
				
		# Change direction rotating the vector
		random += 1
		random %= 4
		direction = DIRECTIONS[random]
	
	return false


func _generate_branches() -> void:
	var branches_created: int = 0
	var candidate: Vector2i
	while branches_created < _branches and _branch_candidates.size() > 0:
		candidate = _branch_candidates[randi_range(0, _branch_candidates.size() - 1)]
		# Try to generate a branch starting from this candidate
		if _generate_path(candidate, randi_range(_branch_length.x, _branch_length.y)):
			branches_created += 1
		else:
			# If no direction is valid starting from this candidate, then remove it from the candidates
			_branch_candidates.erase(candidate)
#endregion

func get_dimensions() -> Vector2i:
	return _dimensions

func get_entrance_position() -> Vector2i:
	return _start

# Check if cell is occupied by a room
func has_room(pos:Vector2i) -> bool:
	return _grid[pos.x][pos.y] != Contents.EMPTY

# Get a list of all room positions in the dungeon. Useful for iteration.
func get_all_room_positions() -> Array[Vector2i]:
	var rooms:Array[Vector2i] = []
	for y in _dimensions.y:
		for x in _dimensions.x:
			var pos:Vector2i = Vector2i(x,y)
			if has_room(pos):
				rooms.append(pos)

	return rooms

#region Bitmask

# Check door bit of the cell
func has_door(pos: Vector2i, direction: Doors) -> bool:
	return _grid[pos.x][pos.y] & direction != 0

# Get the contents bitmask for the requested cell
func get_cell_bitmask(pos: Vector2i) -> int:
	return _grid[pos.x][pos.y]

# Check if the requested cell has a specific content
func has_content(pos: Vector2i, cont: Contents) -> bool:
	return get_cell_bitmask(pos) & cont != 0

func is_critical_path(pos: Vector2i) -> bool:
	return get_cell_bitmask(pos) & Contents.CRITICAL_PATH != 0

#endregion

func _to_string() -> String:
	var dungeon_str = ""
	for y in _dimensions.y:
		for x in _dimensions.x:
			var tmp_text: String = ("0000%s" % str(_grid[x][y]))
			var cell_str = "\t[%s]" % tmp_text.substr(tmp_text.length()-4) if _grid[x][y] else "\t[   ]"
			dungeon_str = dungeon_str + cell_str
		dungeon_str += "\n"
	return dungeon_str