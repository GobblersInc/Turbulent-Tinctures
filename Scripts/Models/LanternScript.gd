extends Node3D

@onready var light: OmniLight3D = $Lantern/LanternLight
@onready var rng = RandomNumberGenerator.new()
@onready var timer: Timer = $Lantern/Timer

@export var flicker_probability: float
@export var light_out_duration: float
@export var check_interval: float
@export var lights_out_cooldown: float
@export var light_on_or_off: bool

var is_light_on: bool

func _ready():
	timer.connect("timeout", _on_check_timer_timeout)
	is_light_on = light_on_or_off
	if is_light_on:
		timer.start(check_interval)
	else:
		flicker_and_fade_light()

func _on_check_timer_timeout():
	if is_light_on:
		if should_flicker_and_fade():
			flicker_and_fade_light()
		else:
			timer.start(check_interval)
	else:
		turn_light_on()

func turn_light_on():
	var tween = get_tree().create_tween()
	tween.tween_property(light, "light_energy", 6, 1)
	is_light_on = true
	timer.start(lights_out_cooldown)

func should_flicker_and_fade() -> bool:
	return rng.randf() < flicker_probability

func flicker_and_fade_light():
	var tween = get_tree().create_tween()
	var flicker_durations = [0.05, 0.1, 0.1, 0.25, 0.05]
	var flicker_intensities = [7.0, 3, 5, 1, 2]

	for i in range(flicker_durations.size()):
		tween.tween_property(light, "light_energy", flicker_intensities[i], flicker_durations[i])

	tween.tween_property(light, "light_energy", 0.0, 0.4)
	is_light_on = false
	timer.start(light_out_duration)
