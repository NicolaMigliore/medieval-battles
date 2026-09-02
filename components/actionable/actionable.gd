extends Area3D
class_name Actionable

signal dialogue_started
signal dialogue_ended

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"

var _balloon_scene = preload("res://components/dialogue_balloon/balloon.tscn")

func action() -> void:
	DialogueManager.show_dialogue_balloon_scene(_balloon_scene, dialogue_resource, dialogue_start)
	# DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start)
	DialogueManager.dialogue_started.connect(func(_dialogue_resource):dialogue_started.emit())
	DialogueManager.dialogue_ended.connect(func(_dialogue_resource):dialogue_ended.emit())
