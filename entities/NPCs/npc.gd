extends CharacterBody3D
class_name NPC

@onready var animation_tree = $Animation/AnimationTree

@export var sprite_texture: Texture2D
@export var portrait_texture: Texture2D

func _ready() -> void:
	init()

#region Init
func init() -> void:

	# Set Sprite
	if sprite_texture:
		var sprite: Sprite3D = get_node("Sprite3D")
		sprite.texture = sprite_texture
		# Configure shader
		sprite.material_override.set_shader_parameter("texture_albedo", sprite.texture)

	
#endregion


#region Animation

func _travel(state_name: String) -> void:
	var playback : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")
	playback.travel(state_name)


func play_idel_d() -> void:
	_travel("idle_d")

func play_talking() -> void:
	_travel("talking")

#endregion
