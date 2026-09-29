extends Resource
class_name InteractionDefinition

@export_category("Dialogue")
@export var dialogue_res: DialogueResource
@export var dialogue_start: String = "start"

func _init(
	dial_res: DialogueResource,
	dial_start: String = "start"
) -> void:
	dialogue_res = dial_res
	dialogue_start = dial_start


