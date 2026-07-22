extends CharacterBody3D

@onready var animation_player = $Animation/AnimationPlayer

# const SPEED = 300.0
# const JUMP_VELOCITY = -400.0

# Properties
var cur_animation = "front_idle"

var id = "cult_minion"
var actor_name = "cultist minion"
var portrait = null
var is_player_controlled = false

# Stats
@onready var max_hp = 5
@onready var attack_pwr = 1
@onready var block_pwr = 1
@onready var heal_pwr = 1
@onready var boost_pwr = 1

# Runtime attributes
@onready var hp = 5
@onready var block = 0
var boost = 0				# current boost amount to be applied to the next move
var initiative = 1
var actions_per_turn = 1

func _ready():
	animation_player.stop()
	animation_player.play("front_idle")

#region Init
func init(opts) -> void:
	# Configure character

	for key in opts:
		if key != "scene":
			self[key] = opts.get(key, self[key])

	# portrait = opts.get("portrait", portrait)
	# actor_name = opts.get("actor_name", actor_name)
	# actions_per_turn = opts.get("actions_per_turn", actions_per_turn)
	# is_player_controlled = opts.get("is_player_controlled", is_player_controlled)
#endregion


#region Evaluate Action
# NOTE: Can be overridden to give different behaviour to different character types
func evaluate_action(context: Dictionary) -> Dictionary:
	var self_c = context.self_combatant
	var enemies = context.enemies
	var allies = context.allies

	# evaluate action weights
	var weights = {
		"attack" = attack_pwr,
		"heal" = heal_pwr,
		"block" = block_pwr,
		"boost" = boost_pwr
	}

	var max_weight = 0
	var best_action = "wait"
	for action in weights:
		if weights[action] > max_weight:
			max_weight = weights[action]
			best_action = action

	print("[LOG] Action evaluated: %s -> %s" % [best_action, self_c.character.actor_name])

	# TODO: Evaluate the action to take
	return { "action": best_action, "target": self_c }
#endregion
