extends Node3D
class_name Room

var _door_scene = preload("res://dungeons/door.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func add_door(direction_idx: int) -> void:
	var direction: Vector2i = Dungeon.DIRECTIONS[direction_idx]
	var door = _door_scene.instantiate()
	add_child(door)
	var room_size:float = 10
	var door_size:float = 2.5
	var door_offset = room_size/2 + door_size/2
	door.global_position = global_position + Vector3(direction.x, 0, direction.y) * door_offset


func set_room_color(color: Color) -> void:
	var box: CSGBox3D = $CSGBox3D
	box.material.albedo_color = color
