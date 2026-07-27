extends Node

@onready var ally_slots = $AllySlots
@onready var enemy_slots = $EnemySlots
@onready var battle_ui = $"../UI/BattleUI"

var _combatants: Array = []		# List of all combatants
var _remaining: Array = []		# List of combatants that haven't completed actions
var _acted: Array = []			# List of combatant that have completed actions

var cur_unit = null

enum phases { START, CONFIG_ROUND, PICK_UNIT, PICK_ACTION, PICK_TARGET, EXECUTE, DONE }
var phase = null

const actions = {
	"attack": { "name": "attack", "target": "enemy", "stat_key": "attack_pwr" },
	"block": { "name": "block", "target": "ally", "stat_key": "block_pwr" },
	"heal": { "name": "heal", "target": "ally", "stat_key": "heal_pwr" },
	"boost": { "name": "boost", "target": "ally", "stat_key": "boost_pwr" },
	"wait": { "name": "wait", "target": "self", "stat_key": null }
}
var cur_action = null

var target_list: Array = []
var cur_target = null

var execution_message : String = ""

func _ready() -> void:
	# init allies
	for i in BattleData.allies.size():
		var character = BattleData.allies[i].scene.instantiate()
		ally_slots.get_child(i).add_child(character)
		character.init(BattleData.allies[i])
		var actions_per_turn =_get_actions_per_turn(character)
		_combatants.append({ "team": 1, "character": character, "actions_per_turn": actions_per_turn})

	# init enemies
	for i in BattleData.enemies.size():
		var character = BattleData.enemies[i].scene.instantiate()
		enemy_slots.get_child(i).add_child(character)
		character.init(BattleData.enemies[i])		# configure character stats
		var actions_per_turn =_get_actions_per_turn(character)
		_combatants.append({ "team": 2, "character": character, "actions_per_turn": actions_per_turn })

	call_deferred("_set_phase", phases.START)

	# setup initiative panel
	call_deferred("_populate_initiative_panel")

	# _set_phase(phases.PICK_UNIT)

	# Register UI signals
	battle_ui.portrait_selected.connect(_on_target_selected)


func _process(_delta: float) -> void:
	# TODO: cleanup dead

	# TODO: manage block shaders

	# TODO: update action fx

	#region Battle Done
	# Exit battle scene
	if phase == phases.DONE:
		# TODO: check timer and change scene 
		print("Change scene!")

	# show end of battle message
	# TODO: check if battle is over

	#region Pick unit
	# Pick next unit
	# if phase == phases.PICK_UNIT:
		

	#region Pick Action
	# if phase == phases.PICK_ACTION:

	#region Pick Target
	# if phase == phases.PICK_TARGET:
	# 	# TODO: handle player input


	#region Execute
	# if phase == phases.EXECUTE:


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
		_set_phase(phases.PICK_ACTION)
	elif phase == phases.PICK_ACTION:
		if cur_unit.character.is_player_controlled:
			battle_ui.show_ui("PickAction", null)

			# connect buttons
			var vbox = battle_ui.get_node("PickActionPanel/MarginContainer/HBoxContainer/VBoxContainer")
			for button in vbox.get_children():
				if not button.pressed.is_connected(_on_action_selected):
					button.pressed.connect(_on_action_selected.bind(button.name))
		else:
			# Automatic AI action and target picking
			var allies = _combatants.filter(func(c): return c.team == cur_unit.team)
			var enemies = _combatants.filter(func(c): return c.team != cur_unit.team)
			var decision = cur_unit.character.evaluate_action({
				"self_combatant": cur_unit,
				"allies": allies,
				"enemies": enemies
			})
			cur_action = actions[decision.action]
			cur_target = decision.target
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


func _configure_round():
	# populate initiative arrays
	_combatants.sort_custom(func(a,b): return a.character.initiative > b.character.initiative)
	_remaining = []
	_acted = []
	for combatant in _combatants:
		for i in range(combatant.actions_per_turn):
			_remaining.append(combatant)

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

func _on_target_selected(combatant) -> void:
	if phase == phases.PICK_TARGET:
		cur_target = combatant
		battle_ui.set_enabled_portraits(_combatants)
		_set_phase(phases.EXECUTE)


func _do_action() -> void:
	execution_message = "- MISSING MESSAGE -"
	match cur_action.name:
		"attack":
			var amount:float = _get_damage_amount()
			var block_amount = cur_target.character.block
			if block_amount > 0:
				cur_target.character.block = max(0, cur_target.character.block - amount)
				amount = max(0, amount - block_amount)
			cur_target.character.hp -= amount
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
			cur_target.character.hp = min(cur_target.character.max_hp, cur_target.character.hp + amount)
			execution_message = "%s heals %s for %.2f hp" % [
				cur_unit.character.actor_name,
				cur_target.character.actor_name,
				amount
			]
		"block":
			var amount = _get_block_amount()
			cur_target.character.block += amount
			execution_message = "%s shields %s for %.2f shield power bringing the total to %.2f%%" % [
				cur_unit.character.actor_name,
				cur_target.character.actor_name,
				amount,
				cur_target.character.block
			]
		"boost":
			var amount = _get_boost_amount()
			cur_target.character.boost += amount
			execution_message = "%s boosts %s's next action by %d" % [
				cur_unit.character.actor_name,
				cur_target.character.actor_name,
				amount * 100
			]
		"wait":
			execution_message = "%s waits before taking an action" % [
				cur_unit.character.actor_name
			]

	# Clear current boost value
	cur_unit.character.boost = 0

	# show dialog
	battle_ui.show_ui("Execute")
	battle_ui.populate_dialog_panel(execution_message, _end_turn)

	# Update initiative list
	var combatant = _remaining.pop_front()
	if cur_action.name == "wait":
		_remaining.append(combatant)
	else:
		_acted.append(combatant)

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
	var size = _remaining.size()
	if size == 0:
		_set_phase(phases.CONFIG_ROUND)
	else:
		_set_phase(phases.PICK_UNIT)
