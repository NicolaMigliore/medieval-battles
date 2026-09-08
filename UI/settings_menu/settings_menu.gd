extends Control
class_name SettingsMenu

signal requested_close

var local_settings:Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_get_settings()
	_connect_buttons()


func load_settings() -> void:
	_get_settings()
	_sync_ui()


func _get_settings() -> void:
	local_settings = SettingsManager.get_settings().duplicate()

func _connect_buttons() -> void:
	# Gameplay settings
	var gameplay_vbox: VBoxContainer = $VBoxContainer/TabContainer/Gameplay/MarginContainer/VBoxContainer
	var camera_type_button: OptionButton = gameplay_vbox.get_node("CameraType/ItemList")
	camera_type_button.item_selected.connect(func(new_val): local_settings.gameplay_camera_mode = new_val)
	
	var camera_zoom_slider: HSlider = gameplay_vbox.get_node("CameraZoom/HSlider")
	camera_zoom_slider.value_changed.connect(func(new_val): local_settings.gameplay_camera_zoom = new_val)
	
	# Display settings
	var display_vbox: VBoxContainer = $VBoxContainer/TabContainer/Display/MarginContainer/VBoxContainer
	var fullscreen_toggle: CheckButton = display_vbox.get_node("Fullscreen")
	fullscreen_toggle.toggled.connect(func(new_val): local_settings.display_fullscreen = new_val)
	
	# Actions
	var action_box = $VBoxContainer/Actions
	
	var apply_btn: Button = action_box.get_node("ApplyButton")
	apply_btn.pressed.connect(func():
		SettingsManager.apply_settings(local_settings)
		SettingsManager.save_settings()
	)
	
	var close_btn: Button = action_box.get_node("CloseButton")
	close_btn.pressed.connect(func():
		requested_close.emit())

func _sync_ui() -> void:
	# Gameplay settings
	var gameplay_vbox: VBoxContainer = $VBoxContainer/TabContainer/Gameplay/MarginContainer/VBoxContainer
	var camera_type_button: OptionButton = gameplay_vbox.get_node("CameraType/ItemList")
	camera_type_button.selected = local_settings.gameplay_camera_mode
	camera_type_button.grab_focus()
	
	var camera_zoom_slider: HSlider = gameplay_vbox.get_node("CameraZoom/HSlider")
	camera_zoom_slider.value = local_settings.gameplay_camera_zoom
	
	# Display settings
	var display_vbox: VBoxContainer = $VBoxContainer/TabContainer/Display/MarginContainer/VBoxContainer
	var fullscreen_toggle: CheckButton = display_vbox.get_node("Fullscreen")
	fullscreen_toggle.button_pressed = local_settings.display_fullscreen
	
