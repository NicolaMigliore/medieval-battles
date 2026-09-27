extends Resource
class_name CombatantDefinition

var default_base_stats: CombatantClassStats = preload("res://entities/character/character_stats.tres")

@export var scene: PackedScene
@export var sprite_texture: Texture2D
@export var portrait: Texture2D
@export var is_player_controlled: bool = false
@export var actor_name: String = "Combatant"
@export var base_stats: CombatantClassStats
var stats_modifiers: Dictionary = {}
var id: String = ""

func _init(
	new_scene: PackedScene = null,
	new_base_stats: CombatantClassStats = default_base_stats,
	new_sprite_texture: Texture2D = null,
	new_portrait: Texture2D = null,
	new_actor_name: String = "Combatant",
	new_is_player_controlled: bool = false
) -> void:
	scene = new_scene
	base_stats = new_base_stats
	sprite_texture = new_sprite_texture
	portrait = new_portrait
	actor_name = new_actor_name
	is_player_controlled = new_is_player_controlled


func get_effective_stats() -> Dictionary:
	var base: CombatantClassStats = base_stats
	var result: Dictionary = {
		"max_hp": base.max_hp,
		"attack_pwr": base.attack_pwr,
		"block_pwr": base.block_pwr,
		"heal_pwr": base.heal_pwr,
		"boost_pwr": base.boost_pwr,
		"initiative": base.initiative,
		"actions_per_turn": base.actions_per_turn,
		"attack_bias": base.attack_bias,
		"block_bias": base.block_bias,
		"heal_bias": base.heal_bias,
		"boost_bias": base.boost_bias,
	}
	for key in stats_modifiers:
		result[key] = result.get(key, 0) + stats_modifiers[key]
	return result
