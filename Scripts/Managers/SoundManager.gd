extends Node3D

const PAPER_INTERACT_SOUNDS = [
	preload("res://Assets/Audio/SFX/Paper Interact/Paper Interact 001.wav"),
	preload("res://Assets/Audio/SFX/Paper Interact/Paper Interact 002.wav"),
	preload("res://Assets/Audio/SFX/Paper Interact/Paper Interact 003.wav"),
	preload("res://Assets/Audio/SFX/Paper Interact/Paper Interact 004.wav"),
	preload("res://Assets/Audio/SFX/Paper Interact/Paper Interact 005.wav"),
	preload("res://Assets/Audio/SFX/Paper Interact/Paper Interact 006.wav"),
	preload("res://Assets/Audio/SFX/Paper Interact/Paper Interact 007.wav"),
	preload("res://Assets/Audio/SFX/Paper Interact/Paper Interact 008.wav"),
	preload("res://Assets/Audio/SFX/Paper Interact/Paper Interact 009.wav"),
	preload("res://Assets/Audio/SFX/Paper Interact/Paper Interact 010.wav"),
	preload("res://Assets/Audio/SFX/Paper Interact/Paper Interact 011.wav"),
	preload("res://Assets/Audio/SFX/Paper Interact/Paper Interact 012.wav"),
	preload("res://Assets/Audio/SFX/Paper Interact/Paper Interact 013.wav")
]

const POURING_SOUNDS = [
	preload("res://Assets/Audio/SFX/Pouring/Pouring 001.wav"),
	preload("res://Assets/Audio/SFX/Pouring/Pouring 002.wav"),
	preload("res://Assets/Audio/SFX/Pouring/Pouring 003.wav"),
	preload("res://Assets/Audio/SFX/Pouring/Pouring 004.wav")
]

const WATER_MIXING_SOUNDS = [
	preload("res://Assets/Audio/SFX/Water Mixing/Water Mixing 001.wav"),
	preload("res://Assets/Audio/SFX/Water Mixing/Water Mixing 002.wav"),
	preload("res://Assets/Audio/SFX/Water Mixing/Water Mixing 003.wav"),
	preload("res://Assets/Audio/SFX/Water Mixing/Water Mixing 004.wav"),
	preload("res://Assets/Audio/SFX/Water Mixing/Water Mixing 005.wav")
]

const POTION_INTERACT_SOUNDS = [
	preload("res://Assets/Audio/SFX/Potion Interact/Potion Interact 001.wav"),
	preload("res://Assets/Audio/SFX/Potion Interact/Potion Interact 002.wav"), 
	preload("res://Assets/Audio/SFX/Potion Interact/Potion Interact 003.wav"), 
	preload("res://Assets/Audio/SFX/Potion Interact/Potion Interact 004.wav"), 
	preload("res://Assets/Audio/SFX/Potion Interact/Potion Interact 005.wav"), 
	preload("res://Assets/Audio/SFX/Potion Interact/Potion Interact 006.wav"), 
	preload("res://Assets/Audio/SFX/Potion Interact/Potion Interact 007.wav")
]

const GLASS_BREAK_SOUNDS = [
	preload("res://Assets/Audio/SFX/Glass Break/Glass Break 001.wav"),
	preload("res://Assets/Audio/SFX/Glass Break/Glass Break 002.wav"), 
	preload("res://Assets/Audio/SFX/Glass Break/Glass Break 003.wav"), 
	preload("res://Assets/Audio/SFX/Glass Break/Glass Break 004.wav"), 
]

const AMBIENT_SFX = [
	preload("res://Assets/Audio/SFX/Ambient/Ambient Audio.ogg")
]

const SHIP_SOUNDS = [
	preload("res://Assets/Audio/SFX/Creaking/Creaking 001.wav"),
	preload("res://Assets/Audio/SFX/Creaking/Creaking 002.wav"),
	preload("res://Assets/Audio/SFX/Creaking/Creaking 003.wav"),
	preload("res://Assets/Audio/SFX/Creaking/Creaking 004.wav"),
	preload("res://Assets/Audio/SFX/Creaking/Creaking 005.wav"),
	preload("res://Assets/Audio/SFX/Creaking/Creaking 006.wav"),
	preload("res://Assets/Audio/SFX/Creaking/Creaking 007.wav")
]

const LANTERN_RELIGHT_SOUND = [
	preload("res://Assets/Audio/SFX/Match/Match 005.wav")
]

const LANTERN_EXTINGUISH_SOUND = [
	preload("res://Assets/Audio/SFX/Extinguish/Extinguish 004.wav")
]

const BUBBLING_SOUND = [
	preload("res://Assets/Audio/SFX/Bubbling/Bubbling.ogg")
]

const BOILING_WATER_SOUND = [
	preload("res://Assets/Audio/SFX/Boiling Water/Boiling-Water-001.ogg")
]

const BACKGROUND_MUSIC_SOUND = [
	preload("res://Assets/Audio/Music/Sea Shanty 2 (GameJam Version).ogg")
]

var audio_players = {
	"paper": null,
	"water_mixing": null,
	"pouring": null,
	"potion_interact": null,
	"glass_break": null,
	"ambient": null,
	"ship": null,
	"lantern_relight": null,
	"lantern_extinguish": null,
	"bubbling": null,
	"boiling_water": null,
	"background_music": null
}

func _ready():
	randomize()
	instantiate_audio_players()
	play_ambient_music()
	play_background_music()

func play_random_sound(category, sound_list):
	if audio_players.has(category):
		var audio_player = audio_players[category]
		var random_sound = sound_list[randi() % sound_list.size()]
		audio_player.stream = random_sound
		audio_player.play()
	else:
		print("Error: Audio player for category '%s' not found" % category)
		
func play_random_ship_sound():
	play_random_sound("ship", SHIP_SOUNDS)
	
func play_lantern_relight_sound():
	audio_players["lantern_relight"].stream = LANTERN_RELIGHT_SOUND[0]
	audio_players["lantern_relight"].play()
	
func play_lantern_extinguish_sound():
	audio_players["lantern_extinguish"].stream = LANTERN_EXTINGUISH_SOUND[0]
	audio_players["lantern_extinguish"].play()
	
func play_random_paper_sound():
	play_random_sound("paper", PAPER_INTERACT_SOUNDS)
	
func play_random_mixing_sound():
	play_random_sound("pouring", POURING_SOUNDS)
	play_random_sound("water_mixing", WATER_MIXING_SOUNDS)
	
func play_random_potion_interact_sound():
	play_random_sound("potion_interact", POTION_INTERACT_SOUNDS)

func player_random_glass_break_sound():
	play_random_sound("glass_break", GLASS_BREAK_SOUNDS)

func play_ambient_music():
	audio_players["ambient"].stream = AMBIENT_SFX[0]
	audio_players["ambient"].play()
	
func play_random_bubbling_sound():
	audio_players["bubbling"].stream = BUBBLING_SOUND[0]
	audio_players["bubbling"].play()
	
func play_boiling_water_sound():
	audio_players["boiling_water"].stream = BOILING_WATER_SOUND[0]
	audio_players["boiling_water"].play()
	
func play_background_music():
	audio_players["background_music"].stream = BACKGROUND_MUSIC_SOUND[0]
	audio_players["background_music"].play()
	
func instantiate_audio_players() -> void:
	for key in audio_players.keys():
		var audio_player = AudioStreamPlayer.new()
		audio_player.volume_db = -15
		add_child(audio_player)
		audio_players[key] = audio_player
		
		if key == "ambient" or key == "ship":
			audio_player.volume_db = -10
		if key == "background_music":
			audio_player.volume_db = -20
