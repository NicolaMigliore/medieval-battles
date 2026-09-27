extends Node3D
class_name TreasureEncounter

var opened:bool = false
var _treasure_item


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect Actionable trigger
	var actionable = $Chest/Actionable
	actionable.body_entered.connect(on_actionable_entered.bind(actionable))
	actionable.body_exited.connect(on_actionable_exited.bind(actionable))


func on_actionable_entered(body:Node3D, actionable: Actionable) -> void:
	var is_player = body is Character and body.is_player_controlled
	if not is_player:
		return 

	var prompt_sprite = actionable.get_node("PromptSprite")
	prompt_sprite.show()

	# Ste the treasure item reference
	DialogueState.tmp_treasure_item = _treasure_item
	DialogueState.tmp_treasure_encounter = self

func on_actionable_exited(body:Node3D, actionable: Actionable) -> void:
	var is_player = body is Character and body.is_player_controlled
	if not is_player:
		return

	var prompt_sprite = actionable.get_node("PromptSprite")
	prompt_sprite.hide()

	# Ste the treasure item reference
	DialogueState.tmp_treasure_item = null
	DialogueState.tmp_treasure_encounter = null


func set_treasure_item(item) -> void:
	_treasure_item = item

func disable() -> void:
	opened = true

	var actionable = $Chest/Actionable
	for connection in actionable.body_entered.get_connections():
		actionable.body_entered.disconnect(connection["callable"])
	for connection in actionable.body_exited.get_connections():
		actionable.body_exited.disconnect(connection["callable"])
	actionable.queue_free()