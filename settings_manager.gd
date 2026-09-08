extends Node

signal settings_applied_camera_mode(mode:FollowCamera.Mode)
signal settings_applied_camera_zoom(new_zoom: float)

const default_settings: Dictionary = {
	gameplay_camera_mode = 1,
	gameplay_camera_zoom = 0.5,
	display_fullscreen = false
}
var settings: Dictionary = {}


func _ready() -> void:
	load_settings()
	apply_settings()


func load_settings() -> void:
	var saved_settings = {}

	var settings_config = ConfigFile.new()
	var err = settings_config.load("user://settings.cfg")

	if err == OK:
		for section_name in settings_config.get_sections():
			for setting_name in settings_config.get_section_keys(section_name):
				var setting_key = "%s_%s" % [section_name, setting_name]
				var setting_value = settings_config.get_value(section_name, setting_name)
				saved_settings[setting_key] = setting_value

	settings = default_settings.merged(saved_settings, true)

func save_settings() -> void:
	var settings_config = ConfigFile.new()
	for setting_key in settings.keys():
		var parts = setting_key.split("_", true, 1)
		var section_name:String = parts[0]
		var setting_name:String = parts[1]
		settings_config.set_value(section_name, setting_name, settings[setting_key])
	
	settings_config.save("user://settings.cfg")


func get_settings() -> Dictionary:
	return settings

func get_setting(key: String) -> Variant:
	if settings.has(key):
		return settings[key]
	else:
		return null

func apply_settings(new_settings = null) -> void:
	if new_settings:
		settings.merge(new_settings, true)
	
	# Display settings
	if settings.display_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	# Gameplay settings
	settings_applied_camera_mode.emit(settings.gameplay_camera_mode)
	settings_applied_camera_zoom.emit(settings.gameplay_camera_zoom)
