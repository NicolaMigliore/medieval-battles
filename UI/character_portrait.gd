extends Button

var is_active = true
var combatant = null

func setup(combatant_data) -> void:
	combatant = combatant_data
	text = combatant_data.character.actor_name
	icon = combatant_data.character.portrait

func set_active(active:bool) -> void:
	is_active = active
	disabled = not active
	focus_mode = Control.FOCUS_ALL if active else Control.FOCUS_NONE
