extends Node3D

@onready var light : OmniLight3D = $Lantern/LanternLight
@onready var rng = RandomNumberGenerator.new()
@onready var check_timer : Timer = $Lantern/CheckTimer
@onready var lights_out_timer : Timer = $Lantern/LightsOutTimer
@onready var lights_out_cooldown_timer : Timer = $Lantern/LightsOutCooldownTimer

@export var flicker_probability: float
@export var light_out_duration: float
@export var check_interval: float
@export var lights_out_cooldown: float

func _ready():
	check_timer.wait_time = check_interval
	lights_out_timer.wait_time = light_out_duration
	lights_out_cooldown_timer.wait_time = lights_out_cooldown
	
	check_timer.connect("timeout", _on_check_timer_timeout)
	lights_out_timer.connect("timeout", _on_light_out_timer_timeout)
	
	check_timer.start()
	
func _on_check_timer_timeout():
	print("We're in check timer timout")
	# Check the probability and trigger the effect if conditions are met
	if should_flicker_and_fade():
		flicker_and_fade_light()

func _on_light_out_timer_timeout():
	# Turn the light back on and restart the check timer
	var tween = get_tree().create_tween()
	tween.tween_property(light, "light_energy", 6, 1)
	lights_out_cooldown_timer.start()

func should_flicker_and_fade() -> bool:
	# Return true if the random value is less than the flicker probability
	if lights_out_cooldown_timer.is_stopped():
		return rng.randf() < flicker_probability
	return false

func flicker_and_fade_light():
	# Define the flicker durations and intensities
	var tween = get_tree().create_tween()
	var flicker_durations = [0.05, 0.1, 0.1, 0.25, 0.05]  # in seconds
	var flicker_intensities = [7.0, 3, 5, 1, 2]

	# Chain the flicker animations
	for i in range(flicker_durations.size()):
		tween.tween_property(light, "light_energy", flicker_intensities[i], flicker_durations[i])

	# After flickering, fade out the light completely
	tween.tween_property(light, "light_energy", 0.0, .4)  # 2 seconds to fade out
	
	lights_out_timer.start()
