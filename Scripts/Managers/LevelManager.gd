extends Node

@onready var level_timer = get_node("/root/PirateShip/LevelTimer")
@onready var lantern = get_node("/root/PirateShip/Lantern")
@onready var cauldron = get_node("/root/PirateShip/Cauldron")
@onready var level_transition = get_node("/root/PirateShip/LevelTransition")

signal PreparedLevel(starting_potions: Array, required_potion: PotionData)
signal GamePause(is_paused: bool)
signal GameLoss()
signal GameWon()
signal LanternUpdated()

var required_potion: PotionData = null

var LEVEL_CONFIG = LevelConfig.LEVEL_CONFIG
var level = 0

func _ready():
	prepare_level()

	cauldron.CompletedPotion.connect(_on_completed_potion)
	InputManager.ClickAfterGameLoss.connect(_on_LossClick)
	level_timer.TimeOut.connect(_on_LevelTimer_timeout)
	level_transition.TransitionUp.connect(_on_transition_up)
	
func _on_completed_potion(resulting_potion: PotionData, is_final_potion: bool):
	if is_final_potion:
		level += 1
		if level >= len(LEVEL_CONFIG):
			GameWon.emit()
		else:
			level_timer.paused = true
			GamePause.emit(true)

func _on_LossClick():
	restart_game()

func _on_LevelTimer_timeout():
	GameLoss.emit()

func _on_transition_up():
	prepare_level()

func prepare_level():
	set_lantern_values(LEVEL_CONFIG[level])
	set_level_timer(LEVEL_CONFIG[level])

	required_potion = LEVEL_CONFIG[level]["potion"].call(LevelConfig.all_potions)
	
	required_potion.result = null
	
	var starting_potions = required_potion.get_all_leaves()

	level_timer.start()
	level_timer.paused = false
	GamePause.emit(false)
	
	PreparedLevel.emit(starting_potions, required_potion)
	
func restart_game():
	get_tree().reload_current_scene()

func set_level_timer(level_config):
	level_timer.wait_time = level_config.time
	
func set_lantern_values(level_config):
	lantern.flicker_probability = level_config.flicker_probability
	lantern.light_out_duration = level_config.light_out_duration
	lantern.check_interval = level_config.check_interval
	lantern.lights_out_cooldown = level_config.lights_out_cooldown
	lantern.light_on_or_off = level_config.light_on_or_off
	LanternUpdated.emit()
