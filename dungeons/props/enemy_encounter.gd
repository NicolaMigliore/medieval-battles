extends Node3D
class_name EnemyEncounter

signal triggered_enemy_encounter(actionable)
signal begin_battle(encounter: EnemyEncounter, encounter_def:EncounterDefinition)

@onready var _npc: NPC = $NPC
@onready var _actionable: Actionable = $NPC/Actionable

@export var encounter_definition: EncounterDefinition


func _ready() -> void:
	# Connect Actionable trigger
	_actionable.body_entered.connect(on_actionable_entered.bind(_actionable))
	# actionable.body_exited.connect(func(body:Node3D): on_actionable_exited(body, innkeeper_trigger))


func on_actionable_entered(body:Node3D, actionable: Actionable) -> void:
	var is_player = body is Character and body.is_player_controlled
	if not is_player:
		return

	# Auto trigger dialog on enter
	actionable.action(encounter_definition.dialogue_res, encounter_definition.dialogue_start)
	triggered_enemy_encounter.emit(actionable)


func set_follow_camera(cam: FollowCamera) -> void:
	_npc.follow_camera = cam


func set_encounter_definition(definition: EncounterDefinition) -> void:
	encounter_definition = definition
	_actionable.dialogue_contexts = [self, definition]

	# set NPC sprite
	var first_combatant: CombatantDefinition = definition.party[0]
	_npc.set_sprite(first_combatant.sprite_texture)

func request_begin_battle() -> void:
	begin_battle.emit(self, encounter_definition)
