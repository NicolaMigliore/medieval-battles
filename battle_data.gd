extends Node

# const WARRIOR_SPRITES = [
# 	preload("res://entities/warrior/warrior-1.png"),
# 	preload("res://entities/warrior/warrior-2.png"),
# 	preload("res://entities/warrior/warrior-3.png"),
# 	preload("res://entities/warrior/warrior-4.png"),
# 	preload("res://entities/warrior/warrior-5.png"),
# 	preload("res://entities/warrior/warrior-6.png")
# ]

var _base_characters = {
	"warrior_1" = {
		"scene": preload("res://entities/warrior/warrior.tscn"),
		"sprite_texture": preload("res://entities/warrior/warrior-1.png"),
		"portrait": preload("res://entities/warrior/warrior-1-portrait.png"),
		"is_player_controlled": false,
		"actor_name": "Warrior",
	},
	"warrior_2" = {
		"scene": preload("res://entities/warrior/warrior.tscn"),
		"sprite_texture": preload("res://entities/warrior/warrior-2.png"),
		"portrait": preload("res://entities/warrior/warrior-2-portrait.png"),
		"is_player_controlled": false,
		"actor_name": "Warrior",
	},
	"warrior_3" = {
		"scene": preload("res://entities/warrior/warrior.tscn"),
		"sprite_texture": preload("res://entities/warrior/warrior-3.png"),
		"portrait": preload("res://entities/warrior/warrior-3-portrait.png"),
		"is_player_controlled": false,
		"actor_name": "Warrior",
	},
	"warrior_4" = { 
		"scene": preload("res://entities/warrior/warrior.tscn"),
		"sprite_texture": preload("res://entities/warrior/warrior-4.png"),
		"portrait": preload("res://entities/warrior/warrior-4-portrait.png"),
		"is_player_controlled": false,
		"actor_name": "Warrior",
	},
	"minion_1" = {
		"scene": preload("res://entities/minion/minion.tscn"),
		"sprite_texture": preload("res://entities/minion/minion-1.png"),
		"portrait": preload("res://entities/minion/minion-1-portrait.png"),
		"is_player_controlled": false,
		"actor_name": "Minion",
	},
	"minion_2" = {
		"scene": preload("res://entities/minion/minion.tscn"),
		"sprite_texture": preload("res://entities/minion/minion-2.png"),
		"portrait": preload("res://entities/minion/minion-2-portrait.png"),
		"is_player_controlled": false,
		"actor_name": "Minion",
	},
	"minion_3" = {
		"scene": preload("res://entities/minion/minion.tscn"),
		"sprite_texture": preload("res://entities/minion/minion-3.png"),
		"portrait": preload("res://entities/minion/minion-3-portrait.png"),
		"is_player_controlled": false,
		"actor_name": "Minion",
	},
	"minion_4" = { 
		"scene": preload("res://entities/minion/minion.tscn"),
		"sprite_texture": preload("res://entities/minion/minion-4.png"),
		"portrait": preload("res://entities/minion/minion-4-portrait.png"),
		"is_player_controlled": false,
		"actor_name": "Minion",
	},
	"berserker_1" = {
		"scene": preload("res://entities/berserker/berserker.tscn"),
		"sprite_texture": preload("res://entities/berserker/berserker-1.png"),
		"portrait": preload("res://entities/berserker/berserker-1-portrait.png"),
		"is_player_controlled": false,
		"actor_name": "Berserker",
	},
	"berserker_2" = {
		"scene": preload("res://entities/berserker/berserker.tscn"),
		"sprite_texture": preload("res://entities/berserker/berserker-2.png"),
		"portrait": preload("res://entities/berserker/berserker-2-portrait.png"),
		"is_player_controlled": false,
		"actor_name": "Berserker",
	},
	"berserker_3" = {
		"scene": preload("res://entities/berserker/berserker.tscn"),
		"sprite_texture": preload("res://entities/berserker/berserker-3.png"),
		"portrait": preload("res://entities/berserker/berserker-3-portrait.png"),
		"is_player_controlled": false,
		"actor_name": "Berserker",
	},
	"berserker_4" = {
		"scene": preload("res://entities/berserker/berserker.tscn"),
		"sprite_texture": preload("res://entities/berserker/berserker-4.png"),
		"portrait": preload("res://entities/berserker/berserker-4-portrait.png"),
		"is_player_controlled": false,
		"actor_name": "Berserker",
	},
	"mage_1" = {
		"scene": preload("res://entities/mage/mage.tscn"),
		"sprite_texture": preload("res://entities/mage/mage-1.png"),
		"portrait": preload("res://entities/mage/mage-1-portrait.png"),
		"is_player_controlled": false,
		"actor_name": "Mage",
	},
	"mage_2" = {
		"scene": preload("res://entities/mage/mage.tscn"),
		"sprite_texture": preload("res://entities/mage/mage-2.png"),
		"portrait": preload("res://entities/mage/mage-2-portrait.png"),
		"is_player_controlled": false,
		"actor_name": "Mage",
	},
	"mage_3" = {
		"scene": preload("res://entities/mage/mage.tscn"),
		"sprite_texture": preload("res://entities/mage/mage-3.png"),
		"portrait": preload("res://entities/mage/mage-3-portrait.png"),
		"is_player_controlled": false,
		"actor_name": "Mage",
	},
	"mage_4" = {
		"scene": preload("res://entities/mage/mage.tscn"),
		"sprite_texture": preload("res://entities/mage/mage-4.png"),
		"portrait": preload("res://entities/mage/mage-4-portrait.png"),
		"is_player_controlled": false,
		"actor_name": "Mage",
	}
}


# populated before changing scene
var allies: Array[Dictionary] = [ 
	_base_characters.warrior_1.merged({"is_player_controlled": true}, true),
	# _base_characters.warrior_3.merged({"is_player_controlled": true}, true),
]
var enemies: Array[Dictionary] = [
	# _base_characters.berserker_3,
	# _base_characters.berserker_4,
	# _base_characters.warrior_2,
	_base_characters.minion_1.merged({}, true),
	_base_characters.minion_2.merged({}, true),
]
var on_victory: Callable
var on_defeat: Callable
