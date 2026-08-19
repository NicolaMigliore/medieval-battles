extends PanelContainer
class_name CharacterInfoPanel

func set_character_data(character:Character) -> void:
	var vbox = $MarginContainer/VBoxContainer
	# var character = combatant.character
	
	var texture: TextureRect = vbox.get_node("TextureRect")
	texture.texture = character.portrait

	var name_label: Label = vbox.get_node("TitleLabel")
	name_label.text = character.actor_name

	# var stats_text = "[center][table=2 bgcolor=#ffffff]
	# [cell expand=1 border=#ffffff ratio=1.5]HP[/cell][hr][cell expand=1 border=#ffffff ratio=1.0][right]%s/%s[/right][/cell]
	# [cell expand=1 border=#ffffff ratio=1.5]Shield[/cell][hr][hr][cell expand=1 border=#ffffff ratio=1.0][right]%s[/right][/cell]
	# [cell expand=1 border=#ffffff ratio=1.5]Initiative[/cell][cell expand=1 border=#ffffff ratio=1.0][right]%s[/right][/cell]
	# [cell expand=1 border=#ffffff ratio=1.5]Attack[/cell][cell expand=1 border=#ffffff ratio=1.0][right]%s[/right][/cell]
	# [cell expand=1 border=#ffffff ratio=1.5]Block[/cell][cell expand=1 border=#ffffff ratio=1.0][right]%s[/right][/cell]
	# [cell expand=1 border=#ffffff ratio=1.5]Heal[/cell][cell expand=1 border=#ffffff ratio=1.0][right]%s[/right][/cell]
	# [cell expand=1 border=#ffffff ratio=1.5]Boost[/cell][cell expand=1 border=#ffffff ratio=1.0][right]%s[/right][/cell]
	# [/table][/center]" % [
	# 	character.hp,
	# 	character.max_hp,
	# 	character.block,
	# 	character.initiative,
	# 	character.attack_pwr,
	# 	character.block_pwr,
	# 	character.heal_pwr,
	# 	character.boost_pwr,
	# ]
	var stats_text = "[center][table=2 bgcolor=#ffffff]
	[cell expand=1 border=#ffffff ratio=1.5]HP[/cell][hr][cell expand=1 border=#ffffff ratio=1.0][right]%s/%s[/right][/cell]
	[cell expand=1 border=#ffffff ratio=1.5]SHLD[/cell][hr][hr][cell expand=1 border=#ffffff ratio=1.0][right]%s[/right][/cell]
	[cell expand=1 border=#ffffff ratio=1.5]INIT[/cell][cell expand=1 border=#ffffff ratio=1.0][right]%s[/right][/cell]
	[cell expand=1 border=#ffffff ratio=1.5]ATK[/cell][cell expand=1 border=#ffffff ratio=1.0][right]%s[/right][/cell]
	[cell expand=1 border=#ffffff ratio=1.5]BLK[/cell][cell expand=1 border=#ffffff ratio=1.0][right]%s[/right][/cell]
	[cell expand=1 border=#ffffff ratio=1.5]HEL[/cell][cell expand=1 border=#ffffff ratio=1.0][right]%s[/right][/cell]
	[cell expand=1 border=#ffffff ratio=1.5]BST[/cell][cell expand=1 border=#ffffff ratio=1.0][right]%s[/right][/cell]
	[/table][/center]" % [
		character.hp,
		character.max_hp,
		character.block,
		character.initiative,
		character.attack_pwr,
		character.block_pwr,
		character.heal_pwr,
		character.boost_pwr,
	]
	var stats_label: RichTextLabel = vbox.get_node("StatsRichTextLabel")
	stats_label.text = stats_text 
