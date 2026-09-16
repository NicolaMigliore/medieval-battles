extends Node3D
class_name TestDungeonGenerator


const WORLD_ANCHOR: Vector3 = Vector3(0,0, 0)
const ROOM_SIZE: Vector3 = Vector3(4, 4, 4)
var _room_scene: PackedScene = preload("res://dungeons/room.tscn")
var room_dict: Dictionary = {}

@export var _dimensions: Vector2i = Vector2i(7,5)
@export var _start: Vector2i = Vector2i(-1,0)
@export var _critical_path_length: int = 13
@export var _branches: int = 3					# TODO: Implement end of branches (https://www.youtube.com/watch?v=-g1eTeq4JYI&t=604s)
@export var _branch_length: Vector2i = Vector2i(1,4)	# store min max in vecotr, i.e., Vector2i(min, max)
var _branch_candidates: Array[Vector2i]

var dungeon_obj: Dungeon
var room_library: RoomLibrary


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	room_library = RoomLibrary.new()

	dungeon_obj = Dungeon.new()
	dungeon_obj.generate()
	_print_dungeon()
	_draw_dungeon()

	# Place player
	var player: Character = $Character
	if player:
		var entrance_pos: Vector2i = dungeon_obj.get_entrance_position()
		print("entrance: %s" % entrance_pos)
		var player_x = (entrance_pos.x + 1) * ROOM_SIZE.x + 4
		var player_z = (entrance_pos.y + 1) * ROOM_SIZE.z + 4
		player.global_position = Vector3(player_x, 0, player_z)


#region DEBUG
func _unhandled_input(event: InputEvent) -> void:
	var cam: Camera3D = $Camera3D
	var input_dir := Input.get_vector("input_left", "input_right", "input_up", "input_down")
	var speed = 1
	cam.global_position += Vector3(input_dir.x, 0, input_dir.y) * speed
	_sync_labels()
#endregion


#region Print and Draw
func _print_dungeon() -> void:
	print("dungeon_data %s:\n%s" % [_dimensions, dungeon_obj])


func _draw_dungeon() -> void:
	var room_holder = $RoomHolder
	var room: Room
	
	room_dict = {}
	for child in room_holder.get_children():
		child.queue_free()
	
	for cell_pos in dungeon_obj.get_all_room_positions():
		var cell_bitmask: int = dungeon_obj.get_cell_bitmask(cell_pos)
		if cell_bitmask:
			# Instantiate the room scene
			room = _room_scene.instantiate()
			room_holder.add_child(room)
			var room_key = "%d_%d" % [cell_pos.x, cell_pos.y]
			
			# Position room
			var door_size = .25
			var room_offset = ROOM_SIZE.x + door_size * 2
			room.global_position = WORLD_ANCHOR + Vector3(cell_pos.x, 0, cell_pos.y) * room_offset
			print("room pos: %s" % room.position)

			# Configure room mesh
			var doors_bitmask:int = (cell_bitmask & 0b1111)
			print("door_bitmask: %d" % doors_bitmask)
			var room_mesh_and_rotation = room_library.get_room_mesh_and_rotation(doors_bitmask)
			room.set_mesh(room_mesh_and_rotation.mesh, room_mesh_and_rotation.turns)
			
			# Add label
			# var camera: Camera3D = $Camera3D
			var canvas:CanvasLayer = $CanvasLayer
			var lab:Label = Label.new()
			
			var tmp_text: String = ("0000%s" % str(doors_bitmask))
			lab.text = tmp_text.substr(tmp_text.length() - 4)
			lab.add_theme_color_override("font_color", Color.BROWN)
			canvas.add_child(lab)
			# lab.position = camera.unproject_position(room.global_position)
			
			room_dict[room_key] = {
				room = room,
				label = lab
			}
			
			# # Add door scene based on bitmask
			# for i in Dungeon.Doors.size():
			# 	var room_has_door = cell_bitmask & Dungeon.Doors.values()[i]
			# 	if room_has_door:
			# 		room.add_door(i)

			# TODO: set the room contents or pick a pre-made rooms based on bitmask				
			# Set room color / type
			var color:Color = Color.BISQUE 
			
			var is_critical_path = dungeon_obj.has_content(cell_pos, Dungeon.Contents.CRITICAL_PATH)
			if is_critical_path:
				color = Color.AQUAMARINE
			
			var is_start = dungeon_obj.has_content(cell_pos, Dungeon.Contents.ENTRANCE)
			if is_start:
				color = Color.ORANGE
			
			var is_branch_end = dungeon_obj.has_content(cell_pos, Dungeon.Contents.BRANCH_END)
			if is_branch_end:
				color = Color.OLIVE

			var is_objective = dungeon_obj.has_content(cell_pos, Dungeon.Contents.MISSION_OBJECTIVE)
			if is_objective:
				color = Color.YELLOW
			
			room.set_room_color(color)

func _sync_labels() -> void:
	var camera: Camera3D = $Camera3D
	for cell_pos in dungeon_obj.get_all_room_positions():
		var cell_bitmask: int = dungeon_obj.get_cell_bitmask(cell_pos)
		if cell_bitmask:
			# Position room
			var room_key = "%d_%d" % [cell_pos.x, cell_pos.y]
			var room = room_dict[room_key].room
			var label = room_dict[room_key].label
			label.position = camera.unproject_position(room.global_position) + Vector2(-20, 0)

#endregion
