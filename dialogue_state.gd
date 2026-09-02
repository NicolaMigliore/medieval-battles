extends Node


#region Tavern Scene
signal open_mission_selector

#endregion


#region Utility Methods
func get_character_portrait_path(character_name: String) -> String:
	var path = ""
	match character_name:
		"innkeeper":
			path = "res://entities/NPCs/innkeeper/innkeeper-portrait.png"
		"nick quest":
			path = "res://entities/NPCs/nick-quest/nick-quest-portrait.png"
	return path
#endregion
