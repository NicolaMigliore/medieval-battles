extends PanelContainer
class_name CharacterInfoPanel

func set_character_data(combatant:CombatantDefinition, current_hp:float = -1, current_block: float = 0) -> void:
	var vbox = $MarginContainer/VBoxContainer
	# var character = combatant.character
	
	var texture: TextureRect = vbox.get_node("TextureRect")
	texture.texture = combatant.portrait

	var name_label: Label = vbox.get_node("TitleLabel")
	name_label.text = combatant.actor_name


	var stats = combatant.get_effective_stats()
	var display_hp = current_hp if current_hp>0 else stats.max_hp
	var display_block = current_block

	var stats_text = "[center][table=2 bgcolor=#ffffff]
	[cell expand=1 border=#ffffff ratio=1.5]HP[/cell][hr][cell expand=1 border=#ffffff ratio=1.0][right]%s/%s[/right][/cell]
	[cell expand=1 border=#ffffff ratio=1.5]SHLD[/cell][hr][hr][cell expand=1 border=#ffffff ratio=1.0][right]%s[/right][/cell]
	[cell expand=1 border=#ffffff ratio=1.5]INIT[/cell][cell expand=1 border=#ffffff ratio=1.0][right]%s[/right][/cell]
	[cell expand=1 border=#ffffff ratio=1.5]ATK[/cell][cell expand=1 border=#ffffff ratio=1.0][right]%s[/right][/cell]
	[cell expand=1 border=#ffffff ratio=1.5]BLK[/cell][cell expand=1 border=#ffffff ratio=1.0][right]%s[/right][/cell]
	[cell expand=1 border=#ffffff ratio=1.5]HEL[/cell][cell expand=1 border=#ffffff ratio=1.0][right]%s[/right][/cell]
	[cell expand=1 border=#ffffff ratio=1.5]BST[/cell][cell expand=1 border=#ffffff ratio=1.0][right]%s[/right][/cell]
	[/table][/center]" % [
		display_hp,
		stats.max_hp,
		display_block,
		stats.initiative,
		stats.attack_pwr,
		stats.block_pwr,
		stats.heal_pwr,
		stats.boost_pwr,
	]
	var stats_label: RichTextLabel = vbox.get_node("StatsRichTextLabel")
	stats_label.text = stats_text 
