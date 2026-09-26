extends Node

var _scene_stack: Array = []
var _initialized_scenes: Dictionary = {}

var scenes = {
	title = preload("res://game_scenes/title_scene.tscn"),
	tavern = preload("res://game_scenes/tavern_scene.tscn"),
	battle = preload("res://game_scenes/battle_scene.tscn"),
	spar = preload("res://game_scenes/spar_selection_scene.tscn"),
	dungeon = preload("res://game_scenes/dungeon_scene.tscn")
}
var active_scene_name: String = ""
var active_scene = null

func _ready() -> void:
	_push_scene("dungeon")


func _switch_scene(scene_name: String, props: Dictionary = {}) -> void:
	# Transition animation
	var transition_mask = get_node("CanvasLayer/TransitionTextureMask")
	transition_mask.fade_in()
	
	# Call previous scene exit method
	active_scene.on_scene_exited()

	# Configure new active scene
	active_scene_name = scene_name
	active_scene = scenes[scene_name].instantiate()
	add_child(active_scene)

	# Connect signals
	active_scene.requested_switch_scene.connect(_switch_scene)
	active_scene.requested_push_scene.connect(_push_scene)
	active_scene.requested_pop_scene.connect(_pop_scene)	

	# Call scene methods
	active_scene.on_scene_entered(props)


func _push_scene(scene_name: String, props: Dictionary = {}) -> void:
	# Transition animation
	var transition_mask = get_node("CanvasLayer/TransitionTextureMask")
	transition_mask.fade_in()

	# Manage scene stack
	if active_scene:
		active_scene.process_mode = Node.PROCESS_MODE_DISABLED
		# active_scene.paused = true							# TODO: Try this instead
		active_scene.hide()
		_scene_stack.push_back({ name = active_scene_name, scene = active_scene})

	# Configure active scene
	active_scene_name = scene_name
	active_scene = scenes[scene_name].instantiate()
	add_child(active_scene)

	# Connect signals
	active_scene.requested_switch_scene.connect(_switch_scene)
	active_scene.requested_push_scene.connect(_push_scene)
	active_scene.requested_pop_scene.connect(_pop_scene)

	# Call active scene methods
	active_scene.on_scene_entered(props)


func _pop_scene() -> void:
	# Skip if there aren't previous scene to load
	if _scene_stack.size() == 0:
		return

	# Cal active scene method
	active_scene.on_scene_exited()

	# Remove active scene
	active_scene.queue_free()

	# Restore previous scene
	var restored = _scene_stack.pop_back()
	active_scene_name = restored.name							# TODO: Check if active_scene_name is needed
	active_scene = restored.scene
	active_scene.process_mode = Node.PROCESS_MODE_INHERIT
	# active_scene.paused = false								# TODO: Try this instead
	active_scene.show()

	# call restored function
	active_scene.on_scene_restored()
