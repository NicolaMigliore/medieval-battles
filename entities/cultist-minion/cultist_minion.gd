extends CharacterBody3D

@onready var animation_player = $Animation/AnimationPlayer

# const SPEED = 300.0
# const JUMP_VELOCITY = -400.0

# Properties
var cur_animation = "front_idle"

var id = "cult_minion"
var actor_name = "cultist minion"
var portrait = null

# Stats
@onready var max_hp = 5
@onready var attack_pwr = 1
@onready var block_pwr = 1
@onready var heal_pwr = 1
@onready var boost_pwr = 1

# Runtime attributes
@onready var hp = 5
@onready var block = 0
var boost = 0				# current boost amount to be applied to the next move
var initiative = 1
var actions_per_turn = 1

func _ready():
	animation_player.stop()
	animation_player.play("front_idle")

# func _physics_process(delta: float) -> void:
# 	# Add the gravity.
# 	if not is_on_floor():
# 		velocity += get_gravity() * delta

# 	# Handle jump.
# 	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
# 		velocity.y = JUMP_VELOCITY

# 	# Get the input direction and handle the movement/deceleration.
# 	# As good practice, you should replace UI actions with custom gameplay actions.
# 	var direction := Input.get_axis("ui_left", "ui_right")
# 	if direction:
# 		velocity.x = direction * SPEED
# 	else:
# 		velocity.x = move_toward(velocity.x, 0, SPEED)

# 	move_and_slide()


# Character configuration
func init(opts) -> void:
	# Configure character
	portrait = opts.get("portrait", portrait)
	actor_name = opts.get("actor_name", actor_name)
	actions_per_turn = opts.get("actions_per_turn", actions_per_turn)
