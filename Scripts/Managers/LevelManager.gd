extends Node

@onready var game_timer = get_node("/root/PirateShip/LevelTimer")
@onready var fade_to_black = get_node("/root/PirateShip/WorldEnvironment/FadeToBlack")
@onready var popup_text = get_node("/root/PirateShip/CanvasLayer/PopupTextFade")
@onready var timer_fade = get_node("/root/PirateShip/CanvasLayer/TimeLeftFade")
@onready var lantern = get_node("/root/PirateShip/Lantern")
@onready var cauldron = get_node("/root/PirateShip/Cauldron")

signal StartedLevel(starting_potions: Array, required_potion: PotionData)
signal GamePause(is_paused: bool)
signal GameLoss()
signal Recipe(potion_recipe: Array)
signal LanternUpdated()

var required_potion: PotionData = null

const TIMES = {
	"time_before_level_transition": 0.5,
	"fading_in": 1,
	"pause_to_read_text": 1,
	"fading_out": 1,
	"waiting_for_reload": 0.1
}

var LEVEL_CONFIG = LevelConfig.LEVEL_CONFIG
var level = 0

func _ready():
	fade_to_black.fade_from_black(1)
	start_level()

	cauldron.CompletedPotion.connect(_on_completed_potion)
	InputManager.ClickAfterGameLoss.connect(_on_LossClick)
	game_timer.TimeOut.connect(_on_LevelTimer_timeout)
	
func _on_completed_potion(resulting_potion: PotionData, is_final_potion: bool):
	if is_final_potion:
		level += 1
		if level >= len(LEVEL_CONFIG):
			end_game()
		else:
			game_timer.paused = true
			GamePause.emit(true)

			await delay("time_before_level_transition")
			await fade_in("Starting Level " + str(level+1))
			await fade_pause()
			
			resulting_potion.node.can_be_selected = true
			resulting_potion.node.global_position = Vector3(1, 1, 1)
			resulting_potion.clear_values()
			
			start_level()
			
			await fade_out()
		
func _on_LossClick():
	restart_game()

func _on_LevelTimer_timeout():
	GameLoss.emit()
	await delay("time_before_level_transition")
	await fade_in("You lost, wow! Click to restart.")
	await fade_pause()

func end_game():
	await delay("time_before_level_transition")
	await fade_in("You beat the game, wow!")
	await fade_pause()

func start_level():
	set_lantern_values(LEVEL_CONFIG[level])
	set_game_timer(LEVEL_CONFIG[level])

	required_potion = LEVEL_CONFIG[level]["potion"].call(LevelConfig.all_potions)
	
	required_potion.result = null
	
	var starting_potions = required_potion.get_all_leaves()
	var potion_recipe = required_potion.get_all_non_leaves()

	StartedLevel.emit(starting_potions, required_potion)
		
	game_timer.start()
	game_timer.paused = false
	GamePause.emit(false)
	Recipe.emit(potion_recipe)
	
func restart_game():
	get_tree().reload_current_scene()
	await fade_out()

func delay(timer_name: String):
	await get_tree().create_timer(TIMES[timer_name]).timeout

func fade_in(input_text: String):
	fade_to_black.fade_to_black(1)
	
	popup_text.fade_text_in(input_text)
	timer_fade.fade_text_out()

	await delay("fading_in")
	
func fade_pause():
	fade_to_black.playback_active = false
	popup_text.playback_active = false
	timer_fade.playback_active = false

	await delay("pause_to_read_text")
	
func fade_out():
	fade_to_black.fade_from_black(1)
	
	popup_text.fade_text_out()
	timer_fade.fade_text_in()
	
	timer_fade.playback_active = true
	fade_to_black.playback_active = true
	popup_text.playback_active = true
	await delay("fading_out")

func set_game_timer(level_config):
	game_timer.wait_time = level_config.game_timer
	
func set_lantern_values(level_config):
	lantern.flicker_probability = level_config.flicker_probability
	lantern.light_out_duration = level_config.light_out_duration
	lantern.check_interval = level_config.check_interval
	lantern.lights_out_cooldown = level_config.lights_out_cooldown
	lantern.light_on_or_off = level_config.light_on_or_off
	LanternUpdated.emit()
