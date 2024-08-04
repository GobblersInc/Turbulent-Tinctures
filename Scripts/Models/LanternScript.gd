extends Node3D

@onready var light: OmniLight3D = $Lantern/LanternLight
@onready var rng = RandomNumberGenerator.new()
@onready var timer: Timer = $Lantern/Timer

@export var flicker_probability: float
@export var light_out_duration: float
@export var check_interval: float
@export var lights_out_cooldown: float
@export var light_on_or_off: bool

var tween: Tween
var is_light_on: bool

signal LightOff()
signal LightOn()

func _ready():
	timer.connect("timeout", _on_check_timer_timeout)
	LevelManager.LanternUpdated.connect(_lantern_settings_updated)
	is_light_on = light_on_or_off
	if is_light_on:
		timer.start(check_interval)
	else:
		flicker_and_fade_light()
	
func _lantern_settings_updated():
	is_light_on = light_on_or_off
	if is_light_on:
		turn_light_on()
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
		start_light_cooldown_timer()

func turn_light_on():
	if tween:
		tween.kill() # Abort the previous animation.
	tween = create_tween()
	SoundManager.play_lantern_relight_sound()
	tween.tween_property(light, "light_energy", 6, 1)
	is_light_on = true
	LightOn.emit()
	
func start_light_cooldown_timer():
	timer.start(lights_out_cooldown)
	
func should_flicker_and_fade() -> bool:
	return rng.randf() < flicker_probability

func flicker_and_fade_light():
	if tween:
		tween.kill() # Abort the previous animation.
	tween = create_tween()
	var flicker_durations = [0.05, 0.1, 0.1, 0.25, 0.05]
	var flicker_intensities = [7.0, 3, 5, 1, 2]
	
	SoundManager.play_lantern_extinguish_sound()
	
	for i in range(flicker_durations.size()):
		tween.tween_property(light, "light_energy", flicker_intensities[i], flicker_durations[i])

	tween.tween_property(light, "light_energy", 0.0, 0.4)
	is_light_on = false
	await tween.finished
	LightOff.emit()
	timer.start(light_out_duration)
	
