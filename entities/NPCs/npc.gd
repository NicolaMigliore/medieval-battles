extends CharacterBody3D
class_name NPC

@onready var animation_tree = $Animation/AnimationTree

@export var sprite_texture: Texture2D
@export var portrait_texture: Texture2D
@export var follow_camera: FollowCamera

var _cur_facing_state: String = ""

func _ready() -> void:
	init()

#region Init
func init() -> void:

	# Set Sprite
	if sprite_texture:
		var sprite: Sprite3D = get_node("Sprite3D")
		sprite.texture = sprite_texture
		# Configure shader
		# sprite.material_override.set_shader_parameter("texture_albedo", sprite.texture)

	
#endregion


#region Process
func _process(_delta: float) -> void:
	if follow_camera:
		_set_animation_rotation()

#endregion


#region Animation

func _travel(state_name: String) -> void:
	var playback : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")
	playback.travel(state_name)

func play_idle_d() -> void:
	_travel("idle_d")

func play_idle_l() -> void:
	_travel("idle_l")

func play_idle_r() -> void:
	_travel("idle_r")

func play_idle_u() -> void:
	_travel("idle_u")

func play_talking() -> void:
	_travel("talking")

func play_idle() -> void:
	_travel("Idle")

func play_talk() -> void:
	_travel("Talk")


func _set_animation_rotation():
	var facing = -global_transform.basis.z
	facing.y = 0
	facing = facing.normalized()

	var h_amount = -facing.dot(follow_camera.get_movement_right())
	var v_amount = -facing.dot(follow_camera.get_movement_forward())

	var blend_position = Vector2(h_amount, v_amount)
	animation_tree["parameters/StateMachine/Idle/blend_position"] = blend_position
	animation_tree["parameters/StateMachine/Talk/blend_position"] = blend_position

	# var new_state:String
	# if new_state != _cur_facing_state:
	# 	_travel(new_state)

#endregion
