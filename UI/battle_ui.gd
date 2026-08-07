extends Control
class_name BattleUI

#region Signals
signal portrait_selected(combattant)
#endregion

var _portrait_scene = preload("res://UI/character_portrait.tscn")
var _hp_bar_scene = preload("res://UI/hp_bar/hp_bar.tscn")

@onready var phase_label = $DebugPanel/PhaseLabel

@onready var dialog_panel = $DialogPanel
@onready var pick_action_panel = $PickActionPanel
@onready var target_info_panel = $TargetInfoPanel
@onready var character_initiative_panel = $CharacterInitiativePanel
var _panels = []
var _hp_bars_dict: Dictionary


func _ready() -> void:
	_hide_all_panels()
	_panels = [
		dialog_panel,
		pick_action_panel,
		target_info_panel,
		character_initiative_panel
	]

#region Panel Visibility
func _hide_all_panels() -> void:
	for child in _panels:
		child.hide()

	# initiative panel always visible
	get_node("CharacterInitiativePanel").show()
	get_node("DebugPanel").show()

# Hide a specific ui element
func hide_ui(panel_name: String) -> void:
	var node = get_node(panel_name)
	if node:
		node.hide()


func update_phase_label(msg) -> void:
	phase_label.text = msg


func show_ui(panel_name: String, _data = null) -> void:
	_hide_all_panels()
	
	if panel_name == "Start":
		get_node("CharacterInitiativePanel").hide()
		get_node("DialogPanel").show()

	if panel_name == "PickAction":
		get_node("PickActionPanel").show()
		# Set focus
		$PickActionPanel/MarginContainer/HBoxContainer/VBoxContainer/AttackButton.grab_focus()

	if panel_name == "PickTarget":
		var vbox: VBoxContainer = $CharacterInitiativePanel/MarginContainer/VBoxContainer
		var portraits = vbox.get_children().filter(func(portrait): return portrait.is_active)
		var first_target: Button = portraits[0]
		first_target.grab_focus()
	
	if panel_name == "Execute":
		get_node("DialogPanel").show()
#endregion

#region Initiative Panel
func populate_initiative_panel(remaining, acted) -> void:
	var vbox = $CharacterInitiativePanel/MarginContainer/VBoxContainer
	for child in vbox.get_children():
		child.queue_free()
	
	# populate remaining combatants
	# var remaining_vbox = $CharacterInitiativePanel/MarginContainer/RemainingVBox
	
	for combatant in remaining:
		var portrait:Button = _portrait_scene.instantiate()
		vbox.add_child(portrait)
		portrait.setup(combatant)
		
		# connect signals
		portrait.pressed.connect(_on_portrait_pressed.bind(combatant))
		portrait.focus_entered.connect(_on_portrait_focused.bind(combatant))
		portrait.focus_exited.connect(_on_portrait_focus_exited.bind(combatant))
		portrait.mouse_entered.connect(_on_portrait_hover_start.bind(combatant))
		portrait.mouse_exited.connect(_on_portrait_hover_end)

	# populate acted combatants
	for combatant in acted:
		var portrait:Button = _portrait_scene.instantiate()
		vbox.add_child(portrait)
		portrait.setup(combatant)
		
		# connect signals
		portrait.pressed.connect(_on_portrait_pressed.bind(combatant))
		portrait.focus_entered.connect(_on_portrait_focused.bind(combatant))
		portrait.focus_exited.connect(_on_portrait_focus_exited.bind(combatant))
		portrait.mouse_entered.connect(_on_portrait_hover_start.bind(combatant))
		portrait.mouse_exited.connect(_on_portrait_hover_end)


func set_enabled_portraits(valid_combatants: Array) -> void:
	# var remaining_vbox = $CharacterInitiativePanel/MarginContainer/RemainingVBox
	# for portrait in remaining_vbox.get_children():
	# 	portrait.set_active(portrait.combatant in valid_combatants)
	
	# var acted_vbox = $CharacterInitiativePanel/MarginContainer/ActedVBox
	# for portrait in acted_vbox.get_children():
	# 	portrait.set_active(portrait.combatant in valid_combatants)

	var vbox = $CharacterInitiativePanel/MarginContainer/VBoxContainer
	for portrait in vbox.get_children():
		portrait.set_active(portrait.combatant in valid_combatants)

func _on_portrait_pressed(combatant) -> void:
	if combatant:
		portrait_selected.emit(combatant)

func _on_portrait_focused(combatant) -> void:
	if combatant:
		populate_info_panel(combatant)
		set_bar_visibility(combatant.idx, true, false)

		# set bar label
		var bars:Array = get_node("HPBars").get_children()
		var hp_bar: HPBar = bars[combatant.idx]
		hp_bar.set_label(combatant.character.actor_name)
	
func _on_portrait_focus_exited(combatant) -> void:
	if combatant:
		set_bar_visibility(combatant.idx, false, false)

func _on_portrait_hover_start(combatant) -> void:
	if combatant:
		populate_info_panel(combatant)

func _on_portrait_hover_end() -> void:
	var info_panel = $TargetInfoPanel
	info_panel.hide()
#endregion

#region Info Panel
func populate_info_panel(combatant) -> void:
	var info_panel = get_node("TargetInfoPanel")
	if not info_panel.visible:
		info_panel.show()

	var vbox = $TargetInfoPanel/MarginContainer/VBoxContainer
	var character = combatant.character
	
	var texture: TextureRect = vbox.get_node("TextureRect")
	texture.texture = character.portrait

	var name_label: Label = vbox.get_node("TitleLabel")
	name_label.text = character.actor_name

	var stats_text = "[center][table=2 bgcolor=#ffffff]
	[cell expand=1 border=#ffffff ratio=1.5]HP[/cell][hr][cell expand=1 border=#ffffff ratio=1.0][right]%s/%s[/right][/cell]
	[cell expand=1 border=#ffffff ratio=1.5]Shield[/cell][hr][hr][cell expand=1 border=#ffffff ratio=1.0][right]%s[/right][/cell]
	[cell expand=1 border=#ffffff ratio=1.5]Initiative[/cell][cell expand=1 border=#ffffff ratio=1.0][right]%s[/right][/cell]
	[cell expand=1 border=#ffffff ratio=1.5]Attack[/cell][cell expand=1 border=#ffffff ratio=1.0][right]%s[/right][/cell]
	[cell expand=1 border=#ffffff ratio=1.5]Block[/cell][cell expand=1 border=#ffffff ratio=1.0][right]%s[/right][/cell]
	[cell expand=1 border=#ffffff ratio=1.5]Heal[/cell][cell expand=1 border=#ffffff ratio=1.0][right]%s[/right][/cell]
	[cell expand=1 border=#ffffff ratio=1.5]Boost[/cell][cell expand=1 border=#ffffff ratio=1.0][right]%s[/right][/cell]
	[/table][/center]" % [
		character.hp,
		character.max_hp,
		character.block,
		character.initiative,
		character.attack_pwr,
		character.block_pwr,
		character.heal_pwr,
		character.boost_pwr,
	]
	var stats_label: RichTextLabel = vbox.get_node("StatsRichTextLabel")
	stats_label.text = stats_text
#endregion

#region Dialog Panel
func populate_dialog_panel(msg: String, _on_advance) -> void:
	var text_label: RichTextLabel = $DialogPanel/MarginContainer/RichTextLabel
	text_label.text= msg

	var advance_button: Button = $DialogPanel/MarginContainer/Container/AdvanceButton
	
	for connection in advance_button.pressed.get_connections():
		advance_button.pressed.disconnect(connection["callable"])

	advance_button.pressed.connect(_on_advance)
	advance_button.grab_focus()
#endregion


#region HP Bars
func populate_hp_bars(combatants) -> void:
	var parent_node = $HPBars
	for child in parent_node.get_children():
		child.queue_free()
	_hp_bars_dict = {}
	
	for combatant in combatants:
		var hp_bar:HPBar = _hp_bar_scene.instantiate()
		parent_node.add_child(hp_bar)
		_hp_bars_dict[combatant.idx] = hp_bar

		# TODO: handle Progress Bar manipulation through custom functions
		var bar:ProgressBar = hp_bar.get_node("ProgressBar")
		bar.value = combatant.character.hp
		bar.max_value = combatant.character.max_hp
		hp_bar.set_label(combatant.character.actor_name)
		hp_bar.hide()


func sync_bar_position(bar_id:int, pos:Vector2) -> void:
	var hp_bar:HPBar = _hp_bars_dict[bar_id]
	if hp_bar:
		hp_bar.position = Vector2(pos)


func set_bar_value(bar_idx: int, value: float) -> void:
	var bars:Array = get_node("HPBars").get_children()
	var hp_bar: HPBar = bars[bar_idx]
	var tween_time: float = 1.0
	hp_bar.tween_bar(value, tween_time)

func set_bar_visibility(bar_idx: int, reveal: bool, auto_hide:bool = false) -> void:
	var bars:Array = get_node("HPBars").get_children()
	var hp_bar: HPBar= bars[bar_idx]
	if reveal:
		hp_bar.show()
		if auto_hide:
			var delay: float = 1.5
			_hide_bar_after_delay(hp_bar, delay)
	else:
		hp_bar.hide()

func _hide_bar_after_delay(hp_bar:HPBar, delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	hp_bar.hide()
#endregion

