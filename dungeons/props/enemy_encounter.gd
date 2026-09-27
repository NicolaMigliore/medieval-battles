extends Node3D
class_name EnemyEncounter

signal triggered_enemy_encounter(actionable)

@onready var _npc: NPC = $NPC
var party:Array[CombatantDefinition]

func _ready() -> void:
	# Connect Actionable trigger
	var actionable = $NPC/Actionable
	actionable.body_entered.connect(
		func(body:Node3D): on_actionable_entered(body, actionable)
	)
	# actionable.body_exited.connect(func(body:Node3D): on_actionable_exited(body, innkeeper_trigger))


func on_actionable_entered(body:Node3D, actionable: Actionable) -> void:
	var is_player = body is Character and body.is_player_controlled
	if not is_player:
		return 

	# Auto trigger dialog on enter
	actionable.action()
	triggered_enemy_encounter.emit(actionable)


func set_follow_camera(cam: FollowCamera) -> void:
	_npc.follow_camera = cam


func set_NPC_sprite(sprite: Texture2D) -> void:
	_npc.set_sprite(sprite)
