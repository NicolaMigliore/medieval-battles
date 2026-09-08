extends CanvasLayer
class_name PauseMenu

signal requested_goto_title

@onready var pause_panel: PanelContainer =$PausePanel
@onready var settings_menu: SettingsMenu = $SettingsMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_connect_buttons()
	
	# register settings signal
	settings_menu.requested_close.connect(_hide_settings)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("input_esc"):
		toggle_pause()
		
		if settings_menu.visible:
			_hide_settings()


#region Pause
func toggle_pause() -> void:
	_set_pause(not get_tree().paused)

func _set_pause(new_pause: bool) -> void:
	if new_pause:
		show()
		var vbox = $PausePanel/VBoxContainer
		var first_btn:Button = vbox.get_children()[0]
		first_btn.grab_focus()
	else:
		hide()

	get_tree().paused = new_pause
#endregion


func _connect_buttons() -> void:
	var vbox = $PausePanel/VBoxContainer

	var return_btn:Button = vbox.get_node("Return")
	return_btn.pressed.connect(func():
		_set_pause(false)
	)

	var settings_btn:Button = vbox.get_node("Settings")
	settings_btn.pressed.connect(func():
		_show_settings()
	)

	var title_btn:Button = vbox.get_node("Title")
	title_btn.pressed.connect(func():
		requested_goto_title.emit()
		_set_pause(false)
	)

#region Settings Menu
func _show_settings() -> void:
	pause_panel.hide()
	settings_menu.load_settings()
	settings_menu.show()

func _hide_settings() -> void:
	settings_menu.hide()
	pause_panel.show()
	
	var return_btn: Button = $PausePanel/VBoxContainer/Return
	return_btn.grab_focus()

#endregion
