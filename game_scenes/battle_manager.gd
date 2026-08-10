extends Node

const ACTIVE_POSITION_OFFSET = .5
const MOVEMENT_SPEED:float = 8.0

@onready var ally_slots = $AllySlots
@onready var enemy_slots = $EnemySlots
@onready var battle_ui:BattleUI = $"../UI/BattleUI"
@onready var camera: Camera3D = $"../Camera3D"

var _combatants: Array = []		# List of all combatants
var _remaining: Array = []		# List of combatants that haven't completed actions
var _acted: Array = []			# List of combatant that have completed actions

var cur_unit = null

enum phases { START, CONFIG_ROUND, PICK_UNIT, PICK_ACTION, PICK_TARGET, EXECUTE, DONE }
var phase = null

const actions = {
	"attack": { "name": "attack", "target": "enemy", "stat_key": "attack_pwr" },
	"block": { "name": "block", "target": "self", "stat_key": "block_pwr" },
	"heal": { "name": "heal", "target": "ally", "stat_key": "heal_pwr" },
	"boost": { "name": "boost", "target": "ally", "stat_key": "boost_pwr" },
	"wait": { "name": "wait", "target": "self", "stat_key": null }
}
var cur_action = null

var target_list: Array = []
var cur_target = null

var execution_message : String = ""

#region Ready
func _ready() -> void:
	# battle_ui = $"../UI/BattleUI"

	var combatant_idx = 0

	# init allies
	for i in BattleData.allies.size():
		var character = BattleData.allies[i].scene.instantiate()
		ally_slots.get_child(i).add_child(character)
		character.init(BattleData.allies[i], false)
		# Update shader (for shield)
		character.get_node("Sprite3D").material_override.set_shader_parameter("shield_active", character.block > 0)


		var actions_per_turn =_get_actions_per_turn(character)

		_combatants.append({
			"idx": combatant_idx,
			"team": 1,
			"character": character,
			"actions_per_turn": actions_per_turn,
			# "destination": null
			"is_active" : true
		})
		combatant_idx += 1

	# init enemies
	for i in BattleData.enemies.size():
		var character = BattleData.enemies[i].scene.instantiate()
		enemy_slots.get_child(i).add_child(character)
		character.init(BattleData.enemies[i], true)		# configure character stats
		var actions_per_turn =_get_actions_per_turn(character)
		_combatants.append({
			"idx": combatant_idx,
			"team": 2,
			"character": character,
			"actions_per_turn": actions_per_turn,
			# "destination": null
			"is_active": true	
		})
		combatant_idx += 1

	call_deferred("_set_phase", phases.START)

	# setup initiative panel
	call_deferred("_populate_initiative_panel")

	# setup hp bars
	call_deferred("_populate_hp_bars")

	# _set_phase(phases.PICK_UNIT)

	# Register UI signals
	battle_ui.portrait_selected.connect(_on_target_selected)
#endregion

#region Process
func _process(_delta: float) -> void:
	# Sync HP bars (needed for self heals)
	_sync_all_bar_positions()
#endregion


#region Set Phase
func _set_phase(new_phase, data = null):
	phase = new_phase
	battle_ui.update_phase_label("Phase: %s" % phase)

	if phase == phases.START:
		battle_ui.show_ui("Start")
		var start_msg = "Battle Starts"
		battle_ui.populate_dialog_panel(start_msg, func():
			_set_phase(phases.CONFIG_ROUND)
			_populate_initiative_panel()
		)
	elif phase == phases.CONFIG_ROUND:
		_configure_round()
		_set_phase(phases.PICK_UNIT)
	elif phase == phases.PICK_UNIT:
		cur_unit = _remaining[0]
		# move forward character
		var old_pos = Vector3(cur_unit.character.global_position)
		var offset_value = -ACTIVE_POSITION_OFFSET if cur_unit.team == 1 else ACTIVE_POSITION_OFFSET
		# _move_to(cur_unit,Vector3(old_pos.x, old_pos.y, old_pos.z + offset_value))
		cur_unit.character.lerp_to(Vector3(old_pos.x, old_pos.y, old_pos.z + offset_value))

		_set_phase(phases.PICK_ACTION)
	elif phase == phases.PICK_ACTION:				# Needed to position the bar for self healing
		if cur_unit.character.is_player_controlled:
			battle_ui.show_ui("PickAction", null)

			# connect buttons
			var vbox = battle_ui.get_node("PickActionPanel/MarginContainer/HBoxContainer/VBoxContainer")
			for button in vbox.get_children():
				if not button.pressed.is_connected(_on_action_selected):
					button.pressed.connect(_on_action_selected.bind(button.name))
		else:
			# Automatic AI action and target picking
			var allies = _combatants.filter(func(c): return c.team == cur_unit.team and c.is_active)
			var enemies = _combatants.filter(func(c): return c.team != cur_unit.team and c.is_active)
			var decision = cur_unit.character.evaluate_action({
				"self_combatant": cur_unit,
				"allies": allies,
				"enemies": enemies
			})
			cur_action = actions[decision.action]
			cur_target = decision.target

			# Simulate thinking time
			await get_tree().create_timer(1.0).timeout

			_set_phase(phases.EXECUTE)
	elif phase == phases.PICK_TARGET:
		# configure target list
		target_list = []
		if cur_action.target == "self":
			target_list = [cur_unit]
		elif cur_action.target == "ally":
			target_list = _combatants.filter(func(combatant:Dictionary): return combatant.team == cur_unit.team)
		elif cur_action.target == "enemy":
			target_list = _combatants.filter(func(combatant:Dictionary): return combatant.team != cur_unit.team)

		battle_ui.set_enabled_portraits(target_list)
		battle_ui.show_ui("PickTarget", data)
	elif phase == phases.EXECUTE:
		_do_action()
	elif phase == phases.DONE:
		var done_message: String = ""
		var defeated_team = data.defeated_team
		if defeated_team == 1:
			done_message = "Party was defeated and had to retreat..."
		else:
			done_message = "Party was victorious!"
		# TODO: Play sounds
		# TODO: assign penalty or reward

		# show dialog
		battle_ui.show_ui("Execute")
		battle_ui.populate_dialog_panel(done_message, _end_battle)
#endregion


func _configure_round():
	# populate initiative arrays
	_remaining = []
	_acted = []
	_combatants.sort_custom(func(a,b): return a.character.initiative > b.character.initiative)
	var active_combatants = _combatants.filter(func(comb): return comb.is_active)
	for combatant in active_combatants:
		for i in range(combatant.actions_per_turn):
			_remaining.append(combatant)

		# Clear unit boost value
		combatant.character.boost = 0
		combatant.character.set_boosted_particles(false)


func _get_actions_per_turn(character):
	# TODO: Implement logic based on charms and disabled actions
	var base = character.actions_per_turn
	var final = base
	return final


func _on_action_selected(button_name: String) -> void:
	# handle chosen action
	match button_name:
		"AttackButton":
			cur_action = actions.attack
		"HealButton":
			cur_action = actions.heal
		"BlockButton":
			cur_action = actions.block
		"BoostButton":
			cur_action = actions.boost
		"WaitButton":
			cur_action = actions.wait
	
	if cur_action == actions.wait:
		_set_phase(phases.EXECUTE)
	else:
		_set_phase(phases.PICK_TARGET)


func _populate_initiative_panel() -> void:
	battle_ui.populate_initiative_panel(_remaining, _acted)

func _populate_hp_bars() -> void:
	battle_ui.populate_hp_bars(_combatants)
	# TODO: Position on the bars over combatants
	# var positions = []
	# for comb in _combatants:
	# 	var pos_2d:Vector2 = camera.unproject_position(comb.character.global_position)
	# 	positions.append(pos_2d)
	# battle_ui.sync_bars_position(positions)
	# _sync_all_bar_positions()

func _on_target_selected(combatant) -> void:
	if phase == phases.PICK_TARGET:
		cur_target = combatant
		battle_ui.set_enabled_portraits(_combatants)
		_set_phase(phases.EXECUTE)


#region Do Action
func _do_action() -> void:
	execution_message = "- MISSING MESSAGE -"
	match cur_action.name:
		"attack":
			var amount:float = _get_damage_amount()
			var block_amount = cur_target.character.block
			if block_amount > 0:
				cur_target.character.block = max(0, cur_target.character.block - amount)
				amount = max(0, amount - block_amount)
				if cur_target.character.block <= 0:
					cur_target.character.get_node("Sprite3D").material_override.set_shader_parameter("shield_active", cur_target.character.block > 0)

			# Animate attacker
			cur_unit.character.play_anticipation()
			var old_pos = Vector3(cur_unit.character.global_position)
			var offset = cur_target.character.global_position.direction_to(old_pos) * .2
			var target_pos = Vector3(cur_target.character.global_position) + offset
			cur_unit.character.play_attack(target_pos, old_pos)
			
			await cur_unit.character.attack_animation_started

			# Animate HP bar
			var new_target_hp = max(0, cur_target.character.hp - amount) 
			battle_ui.set_bar_visibility(cur_target.idx, true, true)
			battle_ui.set_bar_value(cur_target.idx, new_target_hp)

			# Update HP
			cur_target.character.hp = new_target_hp
			
			# Animate target
			cur_target.character.play_hit()
			cur_target.character.set_hit_particles(true)
			await cur_target.character.hit_animation_finished

			# TODO: Check if dead remove from battle
			if cur_target.character.hp <= 0:
				_remaining = _remaining.filter(func(comb): return comb.idx != cur_target.idx)
				_acted = _acted.filter(func(comb): return comb.idx != cur_target.idx)
				cur_target.character.play_death()
				cur_target.is_active= false

			if block_amount > 0:
				execution_message = "%s attacks %s but is blocked by their shield and does %.2f damage" % [
					cur_unit.character.actor_name,
					cur_target.character.actor_name,
					amount
				]
			else:
				execution_message = "%s attacks %s for %.2f damage" % [
					cur_unit.character.actor_name,
					cur_target.character.actor_name,
					amount
				]
		"heal":
			var amount:float = _get_heal_amount()
			var new_target_hp = min(cur_target.character.max_hp, cur_target.character.hp + amount)

			# Animate healer
			cur_unit.character.play_heal_give()
			await cur_unit.character.heal_give_animation_finished

			# Animate target
			cur_target.character.play_heal_take()
			
			# Animate HP bar
			cur_target.character.hp = new_target_hp
			battle_ui.set_bar_visibility(cur_target.idx, true, true)
			battle_ui.set_bar_value(cur_target.idx, new_target_hp)
			
			# Update HP
			cur_target.character.hp = new_target_hp
			
			execution_message = "%s heals %s for %.2f hp" % [
				cur_unit.character.actor_name,
				cur_target.character.actor_name,
				amount
			]
		"block":
			var amount = _get_block_amount()
			cur_target.character.block += amount


			# Animate blocker
			cur_unit.character.play_block()
			# await cur_unit.character.block_animation_finished
			
			cur_unit.character.set_block_particles(true)
			await cur_unit.character.block_particles_finished

			# Update shader
			cur_target.character.get_node("Sprite3D").material_override.set_shader_parameter("shield_active", cur_target.character.block > 0)

			execution_message = "%s shields %s for %.2f shield power bringing the total to %.2f" % [
				cur_unit.character.actor_name,
				cur_target.character.actor_name,
				amount,
				cur_target.character.block
			]
		"boost":
			var amount = _get_boost_amount()
			cur_target.character.boost += amount

			# Animate booster
			cur_unit.character.play_boost_give()
			await cur_unit.character.boost_give_animation_finished

			# Animate target
			cur_target.character.play_boost_take()
			cur_target.character.set_boost_particles(true)
			cur_target.character.set_boosted_particles(true)

			execution_message = "%s boosts %s's next action by %.d%% bringing the total to +%d%%" % [
				cur_unit.character.actor_name,
				cur_target.character.actor_name,
				amount * 100,
				cur_target.character.boost * 100
			]
		"wait":
			execution_message = "%s waits before taking an action" % [
				cur_unit.character.actor_name
			]

	# show dialog
	battle_ui.show_ui("Execute")
	battle_ui.populate_dialog_panel(execution_message, _end_turn)

	# Update initiative list
	var combatant = _remaining.pop_front()
	if cur_action.name == "wait":
		_remaining.append(combatant)
	else:
		_acted.append(combatant)
# endregion

#region Attack
# Get current unit's attack value considering effects and boosts
func _get_damage_amount() -> float:
	var base_dmg = cur_unit.character.attack_pwr
	var boost_amount = base_dmg * cur_unit.character.boost
	
	# TODO: calculate equipment modifiers

	var final_dmg = base_dmg + boost_amount
	return final_dmg
#endregion

#region Heal
func _get_heal_amount() -> float:
	var base_heal = cur_unit.character.heal_pwr
	var boost_amount = base_heal * cur_unit.character.boost

	# TODO: calculate equipment modifiers

	var final_heal = base_heal + boost_amount
	return final_heal
#endregion

# region Block
func _get_block_amount() -> float:
	var base_block = cur_unit.character.block_pwr
	var boost_amount = base_block * cur_unit.character.boost

	# TODO: calculate modifiers
	
	var final_block = base_block + boost_amount
	return final_block
#endregion

# region Boost
func _get_boost_amount() -> float:
	var base_boost = cur_unit.character.boost_pwr

	# TODO: calculate modifiers
	
	var final_boost = base_boost
	return final_boost
#endregion

#region Status Effects
# Add a status effect to the current target
func _add_status_effects(_status_effects:Array) -> void:
	pass
# Apply the effects of status effects to the current target
func _apply_status_effects() -> void:
	pass
#endregion

func _end_turn() -> void:
	_populate_initiative_panel()
	battle_ui.hide_ui("DialogPanel")

	# reset character position
	cur_unit.character.lerp_to(cur_unit.character.get_parent().global_position)
	# Wait some time to complete animations
	await get_tree().create_timer(1.0).timeout

	# Check if battle is over and show end of battle message
	# TODO: check if battle is over
	var t1_active_nbr = _combatants.filter(func(comb): return comb.team == 1 and comb.is_active).size()
	var t2_active_nbr = _combatants.filter(func(comb): return comb.team == 2 and comb.is_active).size()
	if t1_active_nbr == 0:
		_set_phase(phases.DONE, {defeated_team = 1})
		return
	elif t2_active_nbr == 0:
		_set_phase(phases.DONE, {defeated_team = 2})
		return

	var size = _remaining.size()
	if size == 0:
		_set_phase(phases.CONFIG_ROUND)
	else:
		_set_phase(phases.PICK_UNIT)


func _end_battle() -> void:
	get_parent().requested_switch_scene.emit("battle")

#region UI

func _sync_all_bar_positions() -> void:
	for comb in _combatants:
		var pos: Vector2 = camera.unproject_position(comb.character.global_position)
		var control_centering_offset:Vector2 = Vector2(-20,-20)
		var character_offset:Vector2 = Vector2(0,-101)
		pos = pos + control_centering_offset + character_offset
		battle_ui.sync_bar_position(comb.idx, pos)

#endregion