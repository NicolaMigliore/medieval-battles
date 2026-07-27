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
@onready var max_hp: float = 5
@onready var attack_pwr = 1
@onready var block_pwr = 1
@onready var heal_pwr = 1
@onready var boost_pwr = 1

# Bias to incentivize actions
@onready var attack_bias: float = 0
@onready var block_bias: float = 0
@onready var heal_bias: float = 0
@onready var boost_bias: float = 0

# Runtime attributes
@onready var hp: float = 5
@onready var block: float = 0
var boost: float = 0				# current boost amount to be applied to the next move
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
# NOTE: Can be overridden to give different behavior to different character types
func evaluate_action(context: Dictionary) -> Dictionary:
	var self_c = context.self_combatant
	var enemies: Array = context.enemies
	var allies: Array = context.allies

	# evaluate action weights
	var weights = {
		"attack" = attack_bias,
		"heal" = heal_bias,
		"block" = block_bias,
		"boost" = boost_bias
	}

	# healing if allies are weak
	var healing_interest = 0
	for ally in allies:
		if ally.character.hp / ally.character.max_hp < 0.5:
			healing_interest += 0.2
	weights.heal += healing_interest

	# boost if allies have higher attack_pwr
	var boost_interest = 0
	for ally in allies:
		if ally.character.attack_pwr / self_c.character.attack_pwr > 1.2:
			boost_interest += 0.2
	weights.boost += boost_interest

	# shield if high block_pwr
	var highest_block = 0
	for ally in allies:
		if ally.character.block_pwr > highest_block:
			highest_block = ally.character.block_pwr
	var relative_block_pwr = self_c.character.block_pwr / highest_block
	var relative_block_threshold = 0.75
	if relative_block_pwr > relative_block_threshold:
		weights.block += 0.2
	
	# attack if enemies are almost dead
	var attack_interest = 0
	for enemy in enemies:
		var hp_perc = enemy.character.hp / enemy.character.max_hp
		if hp_perc <= 0.2:
			attack_interest += 0.2
	weights.attack += attack_interest

	# Add random bias
	var keys = weights.keys()
	weights[keys.pick_random()] += randf_range(0.05, 0.5)

	# Pick best action
	var max_weight = 0
	var best_action = "wait"
	for action in weights:
		if weights[action] > max_weight:
			max_weight = weights[action]
			best_action = action

	# Select target
	var best_target = self_c
	match best_action:
		"attack":
			best_target = _get_best_attack_target(enemies)
		"heal":
			best_target = _get_best_heal_target(allies)
		"boost":
			best_target = _get_best_boost_target(allies.filter(func(ally): return ally.character != self_c.character))

	print("[DEBUG] Weights:
			attack: %.2f
			heal: %.2f
			block: %.2f
			boost: %.2f" % [weights.attack, weights.heal, weights.block, weights.boost])
	print("[LOG] Action evaluated: %s -> %s" % [best_action, best_target.character.actor_name])

	# TODO: Evaluate the action to take
	return { "action": best_action, "target": best_target }
#endregion


#region Evaluate targets
func _get_best_attack_target(targets:Array):
	var best_weight = 0
	var best_target = targets[0]
	# var log_msg = ""

	for target in targets:
		# prefer targets with less HP
		var target_max_hp: float = target.character.max_hp
		var target_cur_hp: float = target.character.hp
		var base_weight: float = 1 - (target_cur_hp / target_max_hp)
		var weight = base_weight + randf_range(0.0, 0.2)
		if weight > best_weight:
			best_weight = weight
			best_target = target
		
	# 	log_msg = log_msg + "\n\t %s base_weight: %.2f, weight: %.2f" % [target.character.actor_name, base_weight, weight]
	# print("[DEBUG] %s" % log_msg)
	
	return best_target

func _get_best_heal_target(targets:Array):
	var best_weight = 0
	var best_target = targets[0]
	for target in targets:
		# prefer targets with less HP
		var target_max_hp: float = target.character.max_hp
		var target_cur_hp: float = target.character.hp
		var base_weight: float = 1 - (target_cur_hp / target_max_hp)
		var weight = base_weight + randf_range(0.0, 0.2)
		if weight > best_weight:
			best_weight = weight
			best_target = target

	return best_target

func _get_best_boost_target(targets:Array):
	# TODO: Consider implementing logic to decide to boost an attack rather than a defense
	var best_target = targets.pick_random()
	return best_target

#endregion