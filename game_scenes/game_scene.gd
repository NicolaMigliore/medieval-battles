extends Node
class_name GameScene

signal requested_switch_scene(scene_name)

@onready var pause_menu: PauseMenu = $PauseMenu


func _ready() -> void:
	if pause_menu:
		pause_menu.hide()
		pause_menu.requested_goto_title.connect(func(): requested_switch_scene.emit("title"))
