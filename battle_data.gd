extends Node

# const WARRIOR_SPRITES = [
# 	preload("res://entities/warrior/warrior-1.png"),
# 	preload("res://entities/warrior/warrior-2.png"),
# 	preload("res://entities/warrior/warrior-3.png"),
# 	preload("res://entities/warrior/warrior-4.png"),
# 	preload("res://entities/warrior/warrior-5.png"),
# 	preload("res://entities/warrior/warrior-6.png")
# ]

var base_characters = {
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
	},
	"bard_1" = {
		"scene": preload("res://entities/bard/bard.tscn"),
		"sprite_texture": preload("res://entities/bard/bard-1.png"),
		"portrait": preload("res://entities/bard/bard-1-portrait.png"),
		"is_player_controlled": false,
		"actor_name": "Bard",
	},
	"bard_2" = {
		"scene": preload("res://entities/bard/bard.tscn"),
		"sprite_texture": preload("res://entities/bard/bard-2.png"),
		"portrait": preload("res://entities/bard/bard-2-portrait.png"),
		"is_player_controlled": false,
		"actor_name": "Bard",
	},
	"bard_3" = {
		"scene": preload("res://entities/bard/bard.tscn"),
		"sprite_texture": preload("res://entities/bard/bard-3.png"),
		"portrait": preload("res://entities/bard/bard-3-portrait.png"),
		"is_player_controlled": false,
		"actor_name": "Bard",
	},
	"bard_4" = {
		"scene": preload("res://entities/bard/bard.tscn"),
		"sprite_texture": preload("res://entities/bard/bard-4.png"),
		"portrait": preload("res://entities/bard/bard-4-portrait.png"),
		"is_player_controlled": false,
		"actor_name": "Bard",
	},
	"tank_1" = {
		"scene": preload("res://entities/tank/tank.tscn"),
		"sprite_texture": preload("res://entities/tank/tank-1.png"),
		"portrait": preload("res://entities/tank/tank-1-portrait.png"),
		"is_player_controlled": false,
		"actor_name": "Tank",
	},
	"tank_2" = {
		"scene": preload("res://entities/tank/tank.tscn"),
		"sprite_texture": preload("res://entities/tank/tank-2.png"),
		"portrait": preload("res://entities/tank/tank-2-portrait.png"),
		"is_player_controlled": false,
		"actor_name": "Tank",
	},
	"tank_3" = {
		"scene": preload("res://entities/tank/tank.tscn"),
		"sprite_texture": preload("res://entities/tank/tank-3.png"),
		"portrait": preload("res://entities/tank/tank-3-portrait.png"),
		"is_player_controlled": false,
		"actor_name": "Tank",
	},
	"tank_4" = {
		"scene": preload("res://entities/tank/tank.tscn"),
		"sprite_texture": preload("res://entities/tank/tank-4.png"),
		"portrait": preload("res://entities/tank/tank-4-portrait.png"),
		"is_player_controlled": false,
		"actor_name": "Tank",
	}
}


# populated before changing scene
var allies: Array[Dictionary] = [ 
	base_characters.warrior_1.merged({"is_player_controlled": true}, true),
	# base_characters.warrior_3.merged({"is_player_controlled": true}, true),
]

var enemies: Array[Dictionary] = [
	base_characters.minion_1.merged({}, true),
	base_characters.minion_2.merged({}, true),
]
var on_victory: Callable
var on_defeat: Callable

#region Allies
func add_to_allies(unit) -> String:
	# Set ID
	var new_unit_id := str(Time.get_ticks_usec()) + "_" + str(randi())
	unit.id = new_unit_id
	
	unit.is_player_controlled = true
	allies.append(unit)
	return new_unit_id

func get_allies() -> Array:
	return allies

func clear_allies() -> void:
	allies = []

func pop_ally(id: String) -> void:
	var idx: int = allies.find_custom(func(unit): return unit.id == id)
	if idx > -1:
		allies.pop_at(idx)

#endregion


#region Enemies
func add_to_enemies(unit) -> String:
	var new_unit_id := str(Time.get_ticks_usec()) + "_" + str(randi())
	unit.id = new_unit_id
	unit.is_player_controlled = false
	enemies.append(unit)
	return new_unit_id

func get_enemies() -> Array:
	return enemies

func clear_enemies() -> void:
	enemies = []

func pop_enemy(id: String) -> void:
	var idx: int = enemies.find_custom(func(unit): return unit.id == id)
	if idx > -1:
		enemies.pop_at(idx)
#endregion
