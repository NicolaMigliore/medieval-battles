extends Node

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
	switch_scene("dungeon")

func switch_scene(scene_name, init_props:Dictionary = {}) -> void:
	active_scene_name = scene_name
	active_scene = scenes[scene_name].instantiate()
	self.add_child(active_scene)
	if active_scene.has_method("on_scene_entered"):
		active_scene.on_scene_entered(init_props)

	# listen to scene switching event
	for connection in active_scene.requested_switch_scene.get_connections():
		active_scene.requested_switch_scene.disconnect(connection["callable"])
	active_scene.requested_switch_scene.connect(_on_requested_switch_scene)

func _on_requested_switch_scene(scene_name) -> void:
	if scenes.has(scene_name):
		# run current scene unload function
		if active_scene.has_method("unload"):
			active_scene.unload()
		
		# remove scene rom tree
		active_scene.queue_free()
		
		#load new scene
		switch_scene(scene_name)

		var transition_mask = get_node("CanvasLayer/TransitionTextureMask")
		transition_mask.fade_in()
