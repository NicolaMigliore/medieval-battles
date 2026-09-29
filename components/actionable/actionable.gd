extends Area3D
class_name Actionable

signal dialogue_started
signal dialogue_ended

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"

var dialogue_contexts: Array = []		# Additional context to be included in dialogue call

var _balloon_scene = preload("res://components/dialogue_balloon/balloon.tscn")

func action(dialogue_override: DialogueResource = null, start_override: String = "", extra_game_states: Array = []) -> void:
	var resource = dialogue_override if dialogue_override else dialogue_resource
	var start = start_override if not start_override.is_empty() else dialogue_start
	var states = extra_game_states.duplicate()
	for context in dialogue_contexts:
		states.append(context)
	
	DialogueManager.show_dialogue_balloon_scene(_balloon_scene, resource, start, states)
	DialogueManager.dialogue_started.connect(_on_dialogue_started, CONNECT_ONE_SHOT)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended, CONNECT_ONE_SHOT)


func _on_dialogue_started(_dialogue_resource: DialogueResource) -> void:
	# TODO: start talking sfx
	var parent = get_parent()
	if parent.has_method("play_talk"):
		parent.play_talk()

	dialogue_started.emit()

func _on_dialogue_ended(_dialogue_resource: DialogueResource) -> void:
	# Todo: end talking sfx
	var parent = get_parent()
	if parent.has_method("play_idle"):
		parent.play_idle()

	dialogue_ended.emit()

