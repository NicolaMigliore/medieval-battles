extends InteractionDefinition
class_name  TreasureDefinition

@export_category("Item")
@export var item:Dictionary = {"item_name": "Golden Cup"} #TODO: create an ItemDefinition resource


func _init(
	_item: Dictionary,
	dial_res: DialogueResource,
	dial_start: String = "start",
) -> void:
	item = _item
	dialogue_res = dial_res
	dialogue_start = dial_start
