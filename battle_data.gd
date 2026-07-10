extends Node

# populated before changing scene
var allies: Array[Dictionary] = [
	{
		"scene": preload("res://entities/cultist-minion/cultist-minion.tscn"),
		"portrait": preload("res://entities/cultist-minion/cultist-minion-portrait.png"),
		"actor_name": "Elfamir",
		"actions_per_turn": 2
	},
	{
		"scene": preload("res://entities/cultist-minion/cultist-minion.tscn"),
		"portrait": preload("res://entities/cultist-minion/cultist-minion-portrait.png")
	}
]   
var enemies: Array[Dictionary] = [
	{
		"scene": preload("res://entities/skeleton-minion/skeleton-minion.tscn"),
		"portrait": preload("res://entities/skeleton-minion/skeleton-minion-portrait.png")
	},
	{
		"scene": preload("res://entities/skeleton-minion/skeleton-minion.tscn"),
		"portrait": preload("res://entities/skeleton-minion/skeleton-minion-portrait.png")
	}
]
var on_victory: Callable
var on_defeat: Callable
