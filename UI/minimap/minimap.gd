extends Control
class_name Minimap

const DEBUG_SHOW_ALL: bool = false

const CELL_SIZE: float = 16.0
const CELL_GAP: float = 4.0
var _room_style := StyleBoxFlat.new()

var _dungeon: Dungeon
var _player_coords: Vector2i
var _visited_coords: Array[Vector2i]


var dungeon_icons: CompressedTexture2D = preload("res://assets/sprites/dungeon-icons.png")
const ICON_SIZE: Vector2 = Vector2(64, 64)
const ICON_REGIONS: Dictionary = {
	Dungeon.Contents.EMPTY: Rect2(Vector2(0, 0) * ICON_SIZE, ICON_SIZE),
	Dungeon.Contents.MISSION_OBJECTIVE: Rect2(Vector2(1, 0) * ICON_SIZE, ICON_SIZE),
	Dungeon.Contents.ENEMY: Rect2(Vector2(0, 1) * ICON_SIZE, ICON_SIZE),
	Dungeon.Contents.BOSS: Rect2(Vector2(1, 1) * ICON_SIZE, ICON_SIZE),
	Dungeon.Contents.ENTRANCE: Rect2(Vector2(1, 2) * ICON_SIZE, ICON_SIZE),
	Dungeon.Contents.TREASURE: Rect2(Vector2(0, 2) * ICON_SIZE, ICON_SIZE),
}

func _ready() -> void:
	_room_style.set_corner_radius_all(3)


func set_dungeon(dungeon: Dungeon) -> void:
	_dungeon = dungeon

	_player_coords = _dungeon.get_entrance_position()
	_visited_coords = [_player_coords]
	queue_redraw()


func set_player_coords(coords: Vector2i) -> void:
	_player_coords = coords
	queue_redraw()


func set_visited_coords(visited_coords: Array[Vector2i]) -> void:
	_visited_coords = visited_coords
	queue_redraw()

func _draw() -> void:
	if not _dungeon:
		return
	
	var step: float = CELL_SIZE + CELL_GAP
	for pos in _dungeon.get_all_room_positions():
		if not _visited_coords.has(pos) and not DEBUG_SHOW_ALL:
			continue

		var top_left: Vector2 = Vector2(pos.x, pos.y) * step

		# Draw room
		var bitmask: int = _dungeon.get_cell_bitmask(pos)
		var color: Color = _get_room_color(bitmask, pos)
		var rect: Rect2 = Rect2(top_left, Vector2(CELL_SIZE, CELL_SIZE))
		_room_style.bg_color = color
		_room_style.draw(get_canvas_item(), rect)
		
		# Draw doors
		var door_len = CELL_GAP / 2
		if _dungeon.has_door(pos, Dungeon.Doors.RIGHT):
			var start: Vector2 = top_left + Vector2(CELL_SIZE, CELL_SIZE / 2)
			draw_line(start, start + Vector2(door_len, 0), Color.WEB_GRAY, 2)
		if _dungeon.has_door(pos, Dungeon.Doors.LEFT):
			var start: Vector2 = top_left + Vector2(0, CELL_SIZE / 2)
			draw_line(start, start + Vector2(-door_len, 0), Color.WEB_GRAY, 2)
		if _dungeon.has_door(pos, Dungeon.Doors.UP):
			var start: Vector2 = top_left + Vector2(CELL_SIZE / 2, 0)
			draw_line(start, start + Vector2(0, -door_len), Color.WEB_GRAY, 2)
		if _dungeon.has_door(pos, Dungeon.Doors.DOWN):
			var start: Vector2 = top_left + Vector2(CELL_SIZE / 2, CELL_SIZE)
			draw_line(start, start + Vector2(0, +door_len), Color.WEB_GRAY, 2)

		# Draw icon
		_draw_room_icon(bitmask, top_left + Vector2(CELL_SIZE / 2, CELL_SIZE / 2))

func _draw_room_icon(bitmask: int, screen_pos: Vector2) -> void:
	for content_flag in ICON_REGIONS:
		# for all contents in the room
		if bitmask & content_flag:
			var src_rect: Rect2 = ICON_REGIONS[content_flag]
			var dest_size: Vector2 = Vector2(CELL_SIZE, CELL_SIZE) * .5
			var dest_rect: Rect2 = Rect2(screen_pos - dest_size * .5, dest_size)
			draw_texture_rect_region(dungeon_icons, dest_rect, src_rect)
			# break

func _get_room_color(cell_bitmask: int, pos: Vector2i) -> Color:
	var color: Color = Color.WEB_GRAY

	if _player_coords == pos:
		color = Color.GRAY

	return color
