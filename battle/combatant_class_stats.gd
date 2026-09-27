extends Resource
class_name CombatantClassStats

# Stats
@export_category("Stats")
@export var max_hp: float = 5
@export var attack_pwr: float = 1
@export var block_pwr: float = 1
@export var heal_pwr: float = 1
@export var boost_pwr: float = 1
@export var initiative: int = 1
@export var actions_per_turn: int = 1

# Bias to incentivize actions
@export_category("Bias")
@export var attack_bias: float = 0
@export var block_bias: float = 0
@export var heal_bias: float = 0
@export var boost_bias: float = 0
