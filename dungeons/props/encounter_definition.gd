extends InteractionDefinition
class_name EncounterDefinition

@export_category("Dialogue")
@export var display_name: String
@export var portrait_texture: Texture2D

@export_category("Battle")
@export var party: Array[CombatantDefinition]


func _init(
	name: String,
	texture: Texture2D,
	dial_res: DialogueResource,
	dial_start: String = "start",
	enemy_party:Array[CombatantDefinition] = []
) -> void:
	display_name = name
	portrait_texture = texture
	dialogue_res = dial_res
	dialogue_start = dial_start
	party = enemy_party
