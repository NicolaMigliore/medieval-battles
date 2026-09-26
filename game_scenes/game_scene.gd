extends Node
class_name GameScene

signal requested_switch_scene(scene_name, init_props)
signal requested_push_scene(scene_name, init_props)
signal requested_pop_scene()

@onready var pause_menu: PauseMenu = $PauseMenu

func _ready() -> void:
	if pause_menu:
		pause_menu.hide()
		pause_menu.requested_goto_title.connect(func(): requested_switch_scene.emit("title"))


func on_scene_entered(_enter_props: Dictionary) -> void:
	pass

func on_scene_exited() -> void:
	pass

func on_scene_restored() -> void:
	pass