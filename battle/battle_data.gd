extends Node

var base_characters: Dictionary[String,CombatantDefinition] = {
	"warrior_1" = CombatantDefinition.new(
		preload("res://entities/warrior/warrior.tscn"),
		preload("res://entities/warrior/warrior_stats.tres"),
		preload("res://entities/warrior/warrior-1.png"),
		preload("res://entities/warrior/warrior-1-portrait.png"),
		"Warrior",
	),
	"warrior_2" = CombatantDefinition.new(
		preload("res://entities/warrior/warrior.tscn"),
		preload("res://entities/warrior/warrior_stats.tres"),
		preload("res://entities/warrior/warrior-2.png"),
		preload("res://entities/warrior/warrior-2-portrait.png"),
		"Warrior"
	),
	"warrior_3" = CombatantDefinition.new(
		preload("res://entities/warrior/warrior.tscn"),
		preload("res://entities/warrior/warrior_stats.tres"),
		preload("res://entities/warrior/warrior-3.png"),
		preload("res://entities/warrior/warrior-3-portrait.png"),
		"Warrior"
	),
	"warrior_4" = CombatantDefinition.new(
		preload("res://entities/warrior/warrior.tscn"),
		preload("res://entities/warrior/warrior_stats.tres"),
		preload("res://entities/warrior/warrior-4.png"),
		preload("res://entities/warrior/warrior-4-portrait.png"),
		"Warrior"
	),
	"minion_1" = CombatantDefinition.new(
		preload("res://entities/minion/minion.tscn"),
		preload("res://entities/minion/minion_stats.tres"),
		preload("res://entities/minion/minion-1.png"),
		preload("res://entities/minion/minion-1-portrait.png"),
		"Minion"
	),
	"minion_2" = CombatantDefinition.new(
		preload("res://entities/minion/minion.tscn"),
		preload("res://entities/minion/minion_stats.tres"),
		preload("res://entities/minion/minion-2.png"),
		preload("res://entities/minion/minion-2-portrait.png"),
		"Minion"
	),
	"minion_3" = CombatantDefinition.new(
		preload("res://entities/minion/minion.tscn"),
		preload("res://entities/minion/minion_stats.tres"),
		preload("res://entities/minion/minion-3.png"),
		preload("res://entities/minion/minion-3-portrait.png"),
		"Minion"
	),
	"minion_4" = CombatantDefinition.new(
		preload("res://entities/minion/minion.tscn"),
		preload("res://entities/minion/minion_stats.tres"),
		preload("res://entities/minion/minion-4.png"),
		preload("res://entities/minion/minion-4-portrait.png"),
		"Minion"
	),
	"berserker_1" = CombatantDefinition.new(
		preload("res://entities/berserker/berserker.tscn"),
		preload("res://entities/berserker/berserker_stats.tres"),
		preload("res://entities/berserker/berserker-1.png"),
		preload("res://entities/berserker/berserker-1-portrait.png"),
		"Berserker"
	),
	"berserker_2" = CombatantDefinition.new(
		preload("res://entities/berserker/berserker.tscn"),
		preload("res://entities/berserker/berserker_stats.tres"),
		preload("res://entities/berserker/berserker-2.png"),
		preload("res://entities/berserker/berserker-2-portrait.png"),
		"Berserker"
	),
	"berserker_3" = CombatantDefinition.new(
		preload("res://entities/berserker/berserker.tscn"),
		preload("res://entities/berserker/berserker_stats.tres"),
		preload("res://entities/berserker/berserker-3.png"),
		preload("res://entities/berserker/berserker-3-portrait.png"),
		"Berserker"
	),
	"berserker_4" = CombatantDefinition.new(
		preload("res://entities/berserker/berserker.tscn"),
		preload("res://entities/berserker/berserker_stats.tres"),
		preload("res://entities/berserker/berserker-4.png"),
		preload("res://entities/berserker/berserker-4-portrait.png"),
		"Berserker"
	),
	"mage_1" = CombatantDefinition.new(
		preload("res://entities/mage/mage.tscn"),
		preload("res://entities/mage/mage_stats.tres"),
		preload("res://entities/mage/mage-1.png"),
		preload("res://entities/mage/mage-1-portrait.png"),
		"Mage"
	),
	"mage_2" = CombatantDefinition.new(
		preload("res://entities/mage/mage.tscn"),
		preload("res://entities/mage/mage_stats.tres"),
		preload("res://entities/mage/mage-2.png"),
		preload("res://entities/mage/mage-2-portrait.png"),
		"Mage"
	),
	"mage_3" = CombatantDefinition.new(
		preload("res://entities/mage/mage.tscn"),
		preload("res://entities/mage/mage_stats.tres"),
		preload("res://entities/mage/mage-3.png"),
		preload("res://entities/mage/mage-3-portrait.png"),
		"Mage"
	),
	"mage_4" = CombatantDefinition.new(
		preload("res://entities/mage/mage.tscn"),
		preload("res://entities/mage/mage_stats.tres"),
		preload("res://entities/mage/mage-4.png"),
		preload("res://entities/mage/mage-4-portrait.png"),
		"Mage"
	),
	"bard_1" = CombatantDefinition.new(
		preload("res://entities/bard/bard.tscn"),
		preload("res://entities/bard/bard_stats.tres"),
		preload("res://entities/bard/bard-1.png"),
		preload("res://entities/bard/bard-1-portrait.png"),
		"Bard"
	),
	"bard_2" = CombatantDefinition.new(
		preload("res://entities/bard/bard.tscn"),
		preload("res://entities/bard/bard_stats.tres"),
		preload("res://entities/bard/bard-2.png"),
		preload("res://entities/bard/bard-2-portrait.png"),
		"Bard"
	),
	"bard_3" = CombatantDefinition.new(
		preload("res://entities/bard/bard.tscn"),
		preload("res://entities/bard/bard_stats.tres"),
		preload("res://entities/bard/bard-3.png"),
		preload("res://entities/bard/bard-3-portrait.png"),
		"Bard"
	),
	"bard_4" = CombatantDefinition.new(
		preload("res://entities/bard/bard.tscn"),
		preload("res://entities/bard/bard_stats.tres"),
		preload("res://entities/bard/bard-4.png"),
		preload("res://entities/bard/bard-4-portrait.png"),
		"Bard"
	),
	"tank_1" = CombatantDefinition.new(
		preload("res://entities/tank/tank.tscn"),
		preload("res://entities/tank/tank_stats.tres"),
		preload("res://entities/tank/tank-1.png"),
		preload("res://entities/tank/tank-1-portrait.png"),
		"Tank"
	),
	"tank_2" = CombatantDefinition.new(
		preload("res://entities/tank/tank.tscn"),
		preload("res://entities/tank/tank_stats.tres"),
		preload("res://entities/tank/tank-2.png"),
		preload("res://entities/tank/tank-2-portrait.png"),
		"Tank"
	),
	"tank_3" = CombatantDefinition.new(
		preload("res://entities/tank/tank.tscn"),
		preload("res://entities/tank/tank_stats.tres"),
		preload("res://entities/tank/tank-3.png"),
		preload("res://entities/tank/tank-3-portrait.png"),
		"Tank"
	),
	"tank_4" = CombatantDefinition.new(
		preload("res://entities/tank/tank.tscn"),
		preload("res://entities/tank/tank_stats.tres"),
		preload("res://entities/tank/tank-4.png"),
		preload("res://entities/tank/tank-4-portrait.png"),
		"Tank"
	)

}


# populated before changing scene
var allies: Array[CombatantDefinition] = []
var enemies: Array[CombatantDefinition] = []

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
func add_to_enemies(unit:CombatantDefinition) -> String:
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
