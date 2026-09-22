extends Node
class_name GameScene

signal requested_switch_scene(scene_name, init_props)

@onready var pause_menu: PauseMenu = $PauseMenu


func _ready() -> void:
	if pause_menu:
		pause_menu.hide()
		pause_menu.requested_goto_title.connect(func(): requested_switch_scene.emit("title"))


func on_scene_entered(init_props: Dictionary) -> void:
	print("Loaded scene with props: %s" % str(init_props))
