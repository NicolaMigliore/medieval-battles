extends GameScene

@onready var _follow_camera: FollowCamera = $FollowCamera


#region Load and Unload
func on_scene_entered(init_props: Dictionary) -> void:
	var battle_manager = $BattleManager
	if init_props.on_victory:
		battle_manager.on_victory = init_props.on_victory
	if init_props.on_defeat:
		battle_manager.on_defeat = init_props.on_defeat

	_follow_camera.current = true

func on_scene_exited() -> void:
	_follow_camera.current = false

#endregion