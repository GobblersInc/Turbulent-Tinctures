extends Node

@onready var fade_to_black = get_node("/root/PirateShip/WorldEnvironment/FadeToBlack")
@onready var popup_text = get_node("/root/PirateShip/LevelTransition/PopupTextFade")
@onready var timer_fade = get_node("/root/PirateShip/LevelTransition/TimeLeftFade")

const TIMES = {
	"time_before_level_transition": 0.5,
	"fading_in": 1,
	"pause_to_read_text": 1,
	"fading_out": 1,
	"waiting_for_reload": 0.1
}

signal TransitionUp

func _ready():
	#fade_to_black.fade_from_black(1)
	LevelManager.PreparedLevel.connect(_on_started_level)
	LevelManager.GameLoss.connect(_on_game_loss)
	LevelManager.GameWon.connect(_on_game_won)	
	LevelManager.GamePause.connect(_on_game_pause)

func _on_game_loss():
	await delay("time_before_level_transition")
	await fade_in("You lost, wow! Click to restart.")
	await fade_pause()
	
func _on_game_won():
	end_game()

func _on_game_pause(is_game_paused: bool) -> void:
	if is_game_paused:
		await delay("time_before_level_transition")
		await fade_in("Starting Level " + str(LevelManager.level+1))
		await fade_pause()
		
		TransitionUp.emit()
	
func _on_started_level(starting_potions: Array, required_potion: PotionData):
	await fade_out()
	
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
	
func end_game():
	await delay("time_before_level_transition")
	await fade_in("You beat the game, wow!")
	await fade_pause()
	
func delay(timer_name: String):
	await get_tree().create_timer(TIMES[timer_name]).timeout
