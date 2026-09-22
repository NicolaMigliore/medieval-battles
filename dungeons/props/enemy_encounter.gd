extends Node3D
class_name EnemyEncounter

func set_follow_camera(cam: FollowCamera) -> void:
	var character: NPC = get_node("NPC")
	character.follow_camera = cam