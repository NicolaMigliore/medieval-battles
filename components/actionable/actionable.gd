extends Area3D
class_name Actionable

signal dialogue_started
signal dialogue_ended

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"

var _balloon_scene = preload("res://components/dialogue_balloon/balloon.tscn")

func action() -> void:
	DialogueManager.show_dialogue_balloon_scene(_balloon_scene, dialogue_resource, dialogue_start)
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

