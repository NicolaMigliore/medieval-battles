extends Node3D

@onready var external_light: OmniLight3D = $Lantern/ExternalLight

@export var noise_texture: NoiseTexture3D
var time_passed := 0.0
var rand_offset: float = randf()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_passed += delta
	
	var sample_noise = abs(noise_texture.noise.get_noise_1d(time_passed + rand_offset))
	
	const base_energy = 5
	var new_energy = base_energy + sample_noise * 10
	external_light.light_energy = new_energy

	const base_range = .5
	var new_omni_range = base_range + sample_noise * .7
	external_light.omni_range = new_omni_range

