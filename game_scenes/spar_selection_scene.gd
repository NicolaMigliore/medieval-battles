extends Node

signal requested_switch_scene(scene_name)

@onready var allies_units_grid: GridContainer = $Panel/MarginContainer/HBoxContainer/Team1/MarginContainer/VBoxContainer/ScrollContainer/MarginContainer/GridContainer
@onready var enemies_units_grid: GridContainer = $Panel/MarginContainer/HBoxContainer/Team2/MarginContainer/VBoxContainer/ScrollContainer/MarginContainer/GridContainer
@onready var start_button: Button = $Panel/MarginContainer/HBoxContainer/VBoxContainer/Button

var _button_icon_scene = preload("res://UI/icon_button/icon_button.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Build roster grids
	_build_roster(1)
	_build_roster(2)

	# Clear existing teams
	BattleData.clear_allies()
	BattleData.clear_enemies()

	start_button.pressed.connect(_load_battle_scene)


func _load_battle_scene() -> void:
	requested_switch_scene.emit("battle")

#region Allies
func _remove_unit_from_team1(unit_id: String) -> void:

	# index of the unit being removed, before it's gone
	var allies := BattleData.get_allies()
	var removed_idx := allies.find_custom(func(u): return u.id == unit_id)

	BattleData.pop_ally(unit_id)
	var buttons := _sync_active_team_ui(1)

	# Calculate were to give focus after removing
	if buttons.is_empty():
		allies_units_grid.get_child(0).grab_focus()
	else:
		# clamp so removing the last button focuses the new last one (the "previous" neighbor)
		var focus_idx: int = clamp(removed_idx, 0, buttons.size() - 1)
		buttons[focus_idx].call_deferred("grab_focus")

	_update_button_disabled()


func _add_unit_to_team1(unit) -> void:
	const max_slots = 5
	var allies := BattleData.get_allies()

	# Cap team size
	var nbr_allies = BattleData.get_allies().size()
	if nbr_allies == max_slots:
		BattleData.pop_ally(allies[0].id)

	# Add to battle data team
	BattleData.add_to_allies(unit)
	_sync_active_team_ui(1)
	_update_button_disabled()

#endregion


#region Enemies
func _remove_unit_from_team2(unit_id: String) -> void:
	const team_id: int = 2
	var unit_grid: GridContainer
	if team_id == 1:
		unit_grid = allies_units_grid
	else:
		unit_grid = enemies_units_grid

	# index of the unit being removed, before it's gone
	var units := BattleData.get_enemies()
	var removed_idx := units.find_custom(func(u): return u.id == unit_id)

	BattleData.pop_enemy(unit_id)
	var buttons := _sync_active_team_ui(team_id)

	# Calculate were to give focus after removing
	if buttons.is_empty():
		unit_grid.get_child(0).grab_focus()
	else:
		# clamp so removing the last button focuses the new last one (the "previous" neighbor)
		var focus_idx: int = clamp(removed_idx, 0, buttons.size() - 1)
		buttons[focus_idx].call_deferred("grab_focus")

	_update_button_disabled()

func _add_unit_to_team2(unit) -> void:
	const team_id: int = 2
	const max_slots = 5
	var units := BattleData.get_enemies()

	# Cap team size
	var nbr_allies = units.size()
	if nbr_allies == max_slots:
		BattleData.pop_enemy(units[0].id)

	# Add to battle data team
	BattleData.add_to_enemies(unit)
	_sync_active_team_ui(team_id)
	_update_button_disabled()
#endregion

#region Rosters
func _build_roster(team_id: int) -> void:
	var unit_grid: GridContainer
	if team_id == 1:
		unit_grid = allies_units_grid
	else:
		unit_grid = enemies_units_grid

	# clear existing buttons
	for child in unit_grid.get_children():
		child.queue_free()

	# Create all unit buttons
	var base_units = BattleData.base_characters
	var idx = -1
	for unit_key in base_units:
		idx += 1
		var unit = base_units[unit_key]
		var unit_btn: IconButton = _button_icon_scene.instantiate()
		unit_btn.icon_texture = unit.portrait
		unit_btn.icon_size = Vector2(32, 32)
		unit_btn.focus_entered.connect(_set_info_panel.bind(unit))
		unit_btn.mouse_entered.connect(unit_btn.grab_focus)
		if team_id == 1:
			unit_btn.pressed.connect(_add_unit_to_team1.bind(unit))
		else:
			unit_btn.pressed.connect(_add_unit_to_team2.bind(unit))
		unit_grid.add_child(unit_btn)

		if idx == 0:
			unit_btn.grab_focus()
#endregion


#region Teams
func _sync_active_team_ui(team_id: int) -> Array:
	var team_container: HBoxContainer
	var units: Array
	if team_id == 1:
		team_container = $Panel/MarginContainer/HBoxContainer/Team1/MarginContainer/VBoxContainer/ActiveTeam1/HBoxContainer
		units = BattleData.get_allies()
	else:
		team_container = $Panel/MarginContainer/HBoxContainer/Team2/MarginContainer/VBoxContainer/ActiveTeam2/HBoxContainer
		units = BattleData.get_enemies()

	for child in team_container.get_children():
		child.queue_free()
	
	var buttons: Array = []
	for unit in units:
		var team_unit_btn: IconButton = _button_icon_scene.instantiate()
		team_unit_btn.icon_texture = unit.portrait
		team_unit_btn.icon_size = Vector2(32, 32)
		team_unit_btn.focus_entered.connect(_set_info_panel.bind(unit))
		team_unit_btn.mouse_entered.connect(_set_info_panel.bind(unit))
		if team_id == 1:
			team_unit_btn.pressed.connect(_remove_unit_from_team1.bind(unit.id))
		else:
			team_unit_btn.pressed.connect(_remove_unit_from_team2.bind(unit.id))
		team_container.add_child(team_unit_btn)
		buttons.append(team_unit_btn)
	return buttons
#endregion


#region Info Panel
func _set_info_panel(unit) -> void:
	var info_panel:CharacterInfoPanel = $Panel/MarginContainer/HBoxContainer/VBoxContainer/CharacterInfoPanel
	var character: Character = unit.scene.instantiate()
	character.init(unit)
	
	info_panel.set_character_data(character)

#endregion

func _update_button_disabled() -> void:
	var count_t1 = BattleData.get_allies().size()
	var count_t2 = BattleData.get_enemies().size()
	var is_disabled := count_t1 <= 0 or  count_t2 <= 0
	start_button.disabled = is_disabled
