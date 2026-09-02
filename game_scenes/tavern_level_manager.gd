extends Node


@onready var innkeeper_trigger:Actionable = $Innkeeper/Actionable
@onready var nick_trigger:Actionable = $NickQuest/Actionable

func _ready() -> void:
	_setup_triggers()
	_connect_dialogue_signals()


#region Triggers

func _setup_triggers() -> void:
	# Innkeeper trigger
	innkeeper_trigger.body_entered.connect(func(body:Node3D): on_actionable_entered(body, innkeeper_trigger))
	innkeeper_trigger.body_exited.connect(func(body:Node3D): on_actionable_exited(body, innkeeper_trigger))
	# Nick Quest trigger
	nick_trigger.body_entered.connect(func(body:Node3D): on_actionable_entered(body, nick_trigger))
	nick_trigger.body_exited.connect(func(body:Node3D): on_actionable_exited(body, nick_trigger))


func on_actionable_entered(body:Node3D, actionable: Actionable) -> void:
	var is_player = body is Character and body.is_player_controlled
	if not is_player:
		return 
	
	var dialog_sprite = actionable.get_node("DialogueSprite")
	dialog_sprite.hide()

	var prompt_sprite = actionable.get_node("PromptSprite")
	prompt_sprite.show()

func on_actionable_exited(body:Node3D, actionable: Actionable) -> void:
	var is_player = body is Character and body.is_player_controlled
	if not is_player:
		return 
	
	var dialog_sprite = actionable.get_node("DialogueSprite")
	dialog_sprite.show()

	var prompt_sprite = actionable.get_node("PromptSprite")
	prompt_sprite.hide()
#endregion
	
#region Dialogue Signals
func _connect_dialogue_signals() -> void:
	DialogueState.open_mission_selector.connect(on_open_mission_selector)


func on_open_mission_selector() -> void:
	print("Open mission selector")
#endregion
