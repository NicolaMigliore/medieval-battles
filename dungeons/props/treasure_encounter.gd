extends Node3D
class_name TreasureEncounter

@onready var _actionable:Actionable = $Chest/Actionable

@export var treasure_definition: TreasureDefinition

var opened:bool = false
var _treasure_item


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect Actionable trigger
	_actionable.body_entered.connect(on_actionable_entered.bind(_actionable))
	_actionable.body_exited.connect(on_actionable_exited.bind(_actionable))


func on_actionable_entered(body:Node3D, actionable: Actionable) -> void:
	var is_player = body is Character and body.is_player_controlled
	if not is_player:
		return 

	var prompt_sprite = actionable.get_node("PromptSprite")
	prompt_sprite.show()


func on_actionable_exited(body:Node3D, actionable: Actionable) -> void:
	var is_player = body is Character and body.is_player_controlled
	if not is_player:
		return

	var prompt_sprite = actionable.get_node("PromptSprite")
	prompt_sprite.hide()


func set_treasure_definition(definition: TreasureDefinition) -> void:
	treasure_definition = definition
	set_treasure_item(definition.item)


func set_treasure_item(item) -> void:
	_treasure_item = item

	# Set actionable dialogue context
	_actionable.dialogue_contexts = [self, treasure_definition]


func take_treasure() -> void:
	# TODO: Add item to party inventory
	print("treasure_item: %s" % str(_treasure_item))

	# Disable encounter
	opened = true

	var actionable = $Chest/Actionable
	for connection in actionable.body_entered.get_connections():
		actionable.body_entered.disconnect(connection["callable"])
	for connection in actionable.body_exited.get_connections():
		actionable.body_exited.disconnect(connection["callable"])
	actionable.queue_free()