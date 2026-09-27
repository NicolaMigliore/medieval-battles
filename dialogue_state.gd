extends Node


#region Tavern Scene
signal open_mission_selector

#endregion

#region Dungeon Scene
signal begin_battle
signal take_treasure(treasure_item, treasure_encounter)
#endregion

#region Utility State
var tmp_treasure_item
var tmp_treasure_encounter

var tmp_battle_actor_name = null
#


#region Utility Methods
func get_character_portrait_path(character_name: String) -> String:
	var path = ""
	match character_name:
		"innkeeper":
			path = "res://entities/NPCs/innkeeper/innkeeper-portrait.png"
		"nick quest":
			path = "res://entities/NPCs/nick-quest/nick-quest-portrait.png"
		"minion_1":
			path = "res://entities/minion/minion-1-portrait.png"
		"berserker_4":
			path = "res://entities/berserker/berserker-4-portrait.png"
	return path
#endregion
