extends Node

const WARRIOR_SPRITES = [
	preload("res://entities/warrior/warrior-1.png"),
	preload("res://entities/warrior/warrior-2.png"),
	preload("res://entities/warrior/warrior-3.png"),
	preload("res://entities/warrior/warrior-4.png"),
	preload("res://entities/warrior/warrior-5.png"),
	preload("res://entities/warrior/warrior-6.png")
]

# populated before changing scene
var allies: Array[Dictionary] = [
	{
		"scene": preload("res://entities/warrior/warrior.tscn"),
		"sprite_texture": WARRIOR_SPRITES.pick_random(),
		"portrait": preload("res://entities/cultist-minion/cultist-minion-portrait.png"),
		"is_player_controlled": true,
		"actor_name": "Elfamir",
		"actions_per_turn": 2,
		"initiative": 1,
		"block": 0,
		"hp": 1
	},
	{
		"scene": preload("res://entities/warrior/warrior.tscn"),
		"sprite_texture": WARRIOR_SPRITES.pick_random(),
		"portrait": preload("res://entities/cultist-minion/cultist-minion-portrait.png"),
		"is_player_controlled": true,
		"actor_name": "Cultist A",
		"initiative": 2
	},{
		"scene": preload("res://entities/warrior/warrior.tscn"),
		"sprite_texture": WARRIOR_SPRITES.pick_random(),
		"portrait": preload("res://entities/cultist-minion/cultist-minion-portrait.png"),
		"is_player_controlled": true,
		"actor_name": "Elastar",
		"actions_per_turn": 2,
		"initiative": 1,
		"block": 2,
		"hp": 3
	},
	# {
	# 	"scene": preload("res://entities/warrior/warrior.tscn"),
	# 	"sprite_texture": WARRIOR_SPRITES.pick_random(),
	# 	"portrait": preload("res://entities/cultist-minion/cultist-minion-portrait.png"),
	# 	"is_player_controlled": true,
	# 	"actor_name": "Cultist B",
	# 	"initiative": 2
	# },
	# {
	# 	"scene": preload("res://entities/warrior/warrior.tscn"),
	# 	"sprite_texture": WARRIOR_SPRITES.pick_random(),
	# 	"portrait": preload("res://entities/cultist-minion/cultist-minion-portrait.png"),
	# 	"is_player_controlled": true,
	# 	"actor_name": "Cultist C",
	# 	"initiative": 2
	# }
]   
var enemies: Array[Dictionary] = [
	{
		"scene": preload("res://entities/warrior/warrior.tscn"),
		"sprite_texture": WARRIOR_SPRITES.pick_random(),
		"portrait": preload("res://entities/skeleton-minion/skeleton-minion-portrait.png"),
		"is_player_controlled": false,
		"actor_name": "Skeleton A",
		"initiative": 3,
		"attack_bias": 0.3,
		"hp": 0.5
	},
	{
		"scene": preload("res://entities/warrior/warrior.tscn"),
		"sprite_texture": WARRIOR_SPRITES.pick_random(),
		"portrait": preload("res://entities/skeleton-minion/skeleton-minion-portrait.png"),
		"is_player_controlled": false,
		"actor_name": "Skeleton B",
		"initiative": 1,
		"attack_bias": 0.3
	},
	# {
	# 	"scene": preload("res://entities/warrior/warrior.tscn"),
	# 	"sprite_texture": WARRIOR_SPRITES.pick_random(),
	# 	"portrait": preload("res://entities/skeleton-minion/skeleton-minion-portrait.png"),
	# 	"is_player_controlled": false,
	# 	"actor_name": "Skeleton C",
	# 	"initiative": 1,
	# 	"attack_bias": 0.3
	# },
	# {
	# 	"scene": preload("res://entities/warrior/warrior.tscn"),
	# 	"sprite_texture": WARRIOR_SPRITES.pick_random(),
	# 	"portrait": preload("res://entities/skeleton-minion/skeleton-minion-portrait.png"),
	# 	"is_player_controlled": false,
	# 	"actor_name": "Skeleton D",
	# 	"initiative": 1,
	# 	"attack_bias": 0.3
	# },
	# {
	# 	"scene": preload("res://entities/warrior/warrior.tscn"),
	# 	"sprite_texture": WARRIOR_SPRITES.pick_random(),
	# 	"portrait": preload("res://entities/skeleton-minion/skeleton-minion-portrait.png"),
	# 	"is_player_controlled": false,
	# 	"actor_name": "Skeleton E",
	# 	"initiative": 1,
	# 	"attack_bias": 0.3
	# }
]
var on_victory: Callable
var on_defeat: Callable
