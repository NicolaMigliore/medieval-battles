extends Node

# populated before changing scene
var allies: Array[Dictionary] = [
	{
		"scene": preload("res://entities/cultist-minion/cultist-minion.tscn"),
		"portrait": preload("res://entities/cultist-minion/cultist-minion-portrait.png"),
		"is_player_controlled": true,
		"actor_name": "Elfamir",
		"actions_per_turn": 2,
		"initiative": 1
	},
	{
		"scene": preload("res://entities/cultist-minion/cultist-minion.tscn"),
		"portrait": preload("res://entities/cultist-minion/cultist-minion-portrait.png"),
		"is_player_controlled": true,
		"actor_name": "Cultist A",
		"initiative": 2
	}
]   
var enemies: Array[Dictionary] = [
	{
		"scene": preload("res://entities/skeleton-minion/skeleton-minion.tscn"),
		"portrait": preload("res://entities/skeleton-minion/skeleton-minion-portrait.png"),
		"is_player_controlled": false,
		"actor_name": "Skeleton A",
		"initiative": 3
	},
	{
		"scene": preload("res://entities/skeleton-minion/skeleton-minion.tscn"),
		"portrait": preload("res://entities/skeleton-minion/skeleton-minion-portrait.png"),
		"is_player_controlled": false,
		"actor_name": "Skeleton B",
		"initiative": 1
	}
]
var on_victory: Callable
var on_defeat: Callable
