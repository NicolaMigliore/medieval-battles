extends CharacterBody3D
class_name Character

signal attack_animation_started
signal attack_animation_finished
signal hit_animation_finished
signal heal_give_animation_finished
signal block_animation_finished
signal boost_give_animation_finished
signal destination_reached
signal block_particles_finished

@onready var animation_player = $Animation/AnimationPlayer
@onready var animation_tree = $Animation/AnimationTree

# Properties
const SPEED = 1.0
var portrait = null
var is_player_controlled = false

# Mode
enum Mode { EXPLORE, BATTLE }
@export_category("Mode")
@export var mode = Mode.EXPLORE
@export var follow_camera:FollowCamera
@export var overworld_mode: bool = false

# Stats
@export_category("Stats")
@export var actor_name = "character"
@export var max_hp: float = 5
@export var attack_pwr: float = 1
@export var block_pwr: float = 1
@export var heal_pwr: float = 1
@export var boost_pwr: float = 1
@export var initiative = 1
@export var actions_per_turn = 1

# Bias to incentivize actions
@export_category("Combat Bias")
@export var attack_bias: float = 0
@export var block_bias: float = 0
@export var heal_bias: float = 0
@export var boost_bias: float = 0

# Runtime attributes
@onready var hp: float = 5
@onready var block: float = 0
var boost: float = 0				# current boost amount to be applied to the next move

var direction : Vector3 = Vector3.ZERO
var last_dir : Vector3
var _cur_movement_state: String = ""
var _must_lerp: bool = false
var _lerp_destination: Vector3
var _lerp_speed: float

func _ready():
	animation_tree.active = true
	set_mode(mode)


#region Physics
func _physics_process(delta: float) -> void:
	# Lerp during combat
	if _must_lerp:
		global_position = global_position.lerp(_lerp_destination, delta * _lerp_speed)
		if global_position.distance_squared_to(_lerp_destination) < 0.0001:
			_must_lerp = false
			destination_reached.emit()

	# World movement
	if mode == Mode.EXPLORE:
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("input_left", "input_right", "input_up", "input_down")
		if follow_camera:
			var forward := follow_camera.get_movement_forward()
			var right := follow_camera.get_movement_right()

			# Ignore vertical movement
			forward.y = 0
			right.y = 0

			forward = forward.normalized()
			right = right.normalized()
		
			direction = (
				right * input_dir.x +
				forward * -input_dir.y
			).normalized()
		else:
			direction = Vector3(input_dir.x, 0, input_dir.y).normalized()

		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			last_dir = direction
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

		move_and_slide()

		_animate_movement()


func lerp_to(destination: Vector3, speed: float = 8.0) -> void:
	_lerp_destination = destination
	_lerp_speed = speed
	_must_lerp = true
#endregion


#region Init
func init(opts: Dictionary, new_mode:Mode = Mode.EXPLORE) -> void:
	set_mode(new_mode)

	# Set starting HP
	hp = max_hp

	# Configure character
	for key in opts:
		if key != "scene" and key != "sprite_texture" and key != "id":
			self[key] = opts.get(key, self[key])

	# configure sprite
	var sprite: Sprite3D = get_node("Sprite3D")
	if opts.sprite_texture:
		sprite.texture = opts.sprite_texture

	# Configure shader
	sprite.material_override.set_shader_parameter("texture_albedo", sprite.texture)
	

func set_sprite_flip(flip_h = false):
	var sprite: Sprite3D = get_node("Sprite3D")
	sprite.flip_h = flip_h
	
#endregion


#region Mode
func set_mode(new_mode:Mode) -> void:
	mode = new_mode

	# Set billboard mode
	match new_mode:
		Mode.EXPLORE:
			set_shader_parameter("billboard_mode", 2)
			animation_tree["parameters/Transition/transition_request"] = "movement"
		Mode.BATTLE:
			set_shader_parameter("billboard_mode", 1)
			animation_tree["parameters/Transition/transition_request"] = "combat"
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
			var boost_targets = allies.filter(func(ally): return ally.character != self_c.character)
			if allies.size() == 1: boost_targets = allies			# If only one member of the team remains they can boost themselves
			best_target = _get_best_boost_target(boost_targets)

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

#region Animation
func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "character/right_attack":
		attack_animation_finished.emit()
	if anim_name == "character/right_hit":
		hit_animation_finished.emit()
	if anim_name == "character/right_heal_give":
		heal_give_animation_finished.emit()
	if anim_name == "character/right_block":
		block_animation_finished.emit()
	if anim_name == "character/right_boost_give":
		boost_give_animation_finished.emit()

func _travel(state_name: String) -> void:
	var playback : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/CombatStateMachine/playback")
	playback.travel(state_name)

func play_anticipation() -> void:
	_travel("character_right_anticipation")

func play_attack(target_pos: Vector3, return_pos: Vector3) -> void:
	# Move to the target
	var destination: Vector3 = target_pos - global_position.direction_to(target_pos) * 0.08
	lerp_to(Vector3(destination.x, destination.y, destination.z))
	# await get_tree().create_timer(0.7).timeout
	set_run_particles(true)
	await destination_reached

	# Animate attack impact
	_travel("character_right_attack")
	set_run_particles(false)
	await attack_animation_finished

	lerp_to(Vector3(return_pos))
			
func play_hit() -> void:
	_travel("character_right_hit")

func play_death() -> void:
	_travel("character_right_death")

func play_heal_give() -> void:
	_travel("character_right_heal_give")

func play_heal_take() -> void:
	_travel("character_right_heal_take")

func play_block() -> void:
	_travel("character_right_block")

func play_boost_give() -> void:
	_travel("character_right_boost_give")

func play_boost_take() -> void:
	_travel("character_right_boost_take")


func _movement_travel(state_name) -> void:
	var playback : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/MovementStateMachine/playback")
	playback.travel(state_name)

func _animate_movement() -> void:
	var new_movement_state = _cur_movement_state 
	# Moving animations
	if direction:
		var v_amount = direction.dot(follow_camera.get_movement_forward())
		var h_amount = direction.dot(follow_camera.get_movement_right())
		var blend_position = Vector2(h_amount,v_amount)
		animation_tree["parameters/MovementStateMachine/Walk/blend_position"] = blend_position
		new_movement_state = "Walk"

	# Idle animations
	else:
		var v_amount = last_dir.dot(follow_camera.get_movement_forward())
		var h_amount = last_dir.dot(follow_camera.get_movement_right())
		var blend_position = Vector2(h_amount, v_amount)
		animation_tree["parameters/MovementStateMachine/Idle/blend_position"] = blend_position
		new_movement_state = "Idle"

	# Update animation state
	if new_movement_state != _cur_movement_state:
		_movement_travel(new_movement_state)


# Fired when any animation finishes
func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	_on_animation_finished(anim_name)

# Fired when any animation starts
func _on_animation_tree_animation_started(anim_name: StringName) -> void:
	if anim_name == "character/right_attack":
		attack_animation_started.emit()

#endregion

#region Particles
func set_run_particles(emit: bool) -> void:
	var particles: GPUParticles3D = get_node("CollisionShape3D/Particles/RunParticles")
	particles.emitting = emit

func set_hit_particles(emit:bool) -> void:
	var particles: GPUParticles3D = get_node("CollisionShape3D/Particles/HitParticles")
	particles.emitting = emit

func set_hit_shield_particles(emit:bool) -> void:
	var particles: GPUParticles3D = get_node("CollisionShape3D/Particles/HitShieldParticles")
	particles.emitting = emit

func set_heal_give_particles(emit:bool) -> void:
	var particles: GPUParticles3D = get_node("CollisionShape3D/Particles/HealGiveParticles")
	particles.emitting = emit

func set_heal_take_particles(emit:bool) -> void:
	var particles: GPUParticles3D = get_node("CollisionShape3D/Particles/HealTakeParticles")
	particles.emitting = emit

func set_block_particles(emit: bool) -> void:
	var particles: GPUParticles3D = get_node("CollisionShape3D/Particles/BlockParticles")
	particles.emitting = emit

	await particles.finished
	block_particles_finished.emit()

# On shot particles to show that the character is being boosted
func set_boost_particles(emit:bool) -> void:
	var particles: GPUParticles3D = get_node("CollisionShape3D/Particles/BoostParticles")
	particles.emitting = emit

# Persistent particles to show that the character is boosted
func set_boosted_particles(emit:bool) -> void:
	var particles: GPUParticles3D = get_node("CollisionShape3D/Particles/BoostedParticles")
	particles.emitting = emit

#endregion


#region Shader

func set_shader_parameter(param_name: String, value) -> void:	
	var sprite: Sprite3D = get_node("Sprite3D")
	sprite.material_override.set_shader_parameter(param_name, value)

#endregion