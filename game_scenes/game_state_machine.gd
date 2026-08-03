extends Node

var scenes = {
	title = preload("res://game_scenes/title_scene.tscn"),
	battle = preload("res://game_scenes/battle_scene.tscn"),
}
var active_scene_name: String = ""
var active_scene = null

func _ready() -> void:

	# Test Battle scene
	# BattleData.party.append(...)
	# BattleData.enemies = [
	# 	{
	# 		"scene": preload("res://entities/cultist-minion/cultist_minion.tscn"), 
	# 		# TODO: implement character statistics
	# 		"hp": 10,
	# 		"level": 2, 
	# 	},
	# ]
	switch_scene("battle")

func switch_scene(scene_name) -> void:
	active_scene_name = scene_name
	active_scene = scenes[scene_name].instantiate()
	self.add_child(active_scene)

	# listen to scene switching event
	active_scene.requested_switch_scene.connect(_on_requested_switch_scene)

func _on_requested_switch_scene(scene_name) -> void:
	print("got signal")
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
