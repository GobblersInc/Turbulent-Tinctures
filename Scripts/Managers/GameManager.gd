extends Node3D

@onready var fade_to_black = get_node("/root/PirateShip/WorldEnvironment/FadeToBlack")
@onready var popup_text = get_node("/root/PirateShip/CanvasLayer/PopupTextFade")
@onready var timer_fade = get_node("/root/PirateShip/CanvasLayer/TimeLeftFade")
@onready var lantern = get_node("/root/PirateShip/Lantern")
@onready var cauldron = get_node("/root/PirateShip/Cauldron")
@onready var game_timer = get_node("/root/PirateShip/LevelTimer")

var all_potions = {}

const FluidType = preload("res://Scripts/Utilities/PotionData.gd").FluidType
const BottleType = preload("res://Scripts/Utilities/PotionData.gd").BottleType
const LANTERN_SCRIPT_PATH = "res://Scripts/Models/LanternScript.gd"
const LANTERN_SCENE = "res://Scenes/Models/lantern.tscn"

const water_color = Color(0.064, 0.142, 0.482)

const TIMES = {
	"time_before_level_transition": 0.5,
	"fading_in": 1,
	"pause_to_read_text": 1,
	"fading_out": 1,
	"waiting_for_reload": 0.1
}

var cauldron_contents = []
var required_potion = null
var level = 0
var lost = false
var pouring = false
var tween: Tween

signal Recipe(potion_recipe: Array)
signal GameLoss()
signal GamePause(is_paused: bool)
signal MixAttempt()
signal LanternUpdated()
signal FinishedLevel(resulting_potion: PotionData)
signal CompletedPotion(resulting_potion: PotionData)
signal StartedLevel(starting_potions: Array)
signal InitializeGame(all_possible_potions)

"""
The minimum nesting one can do is 1 - otherwise there wouldn't be any potion equations!
"""
var LEVEL_CONFIG = LevelConfig.LEVEL_CONFIG

func set_lantern_values(level_config):
	lantern.flicker_probability = level_config.flicker_probability
	lantern.light_out_duration = level_config.light_out_duration
	lantern.check_interval = level_config.check_interval
	lantern.lights_out_cooldown = level_config.lights_out_cooldown
	lantern.light_on_or_off = level_config.light_on_or_off
	LanternUpdated.emit()

func _ready():
	initialize()
	
	InteractionManager.AddIngredient.connect(_on_AddIngredient)
	InteractionManager.MixIngredients.connect(_on_MixIngredients)
	InputManager.ClickAfterGameLoss.connect(_on_LossClick)
	game_timer.TimeOut.connect(_on_LevelTimer_timeout)	

func _on_LossClick():
	restart_game()

# Function to generate all possible potion combinations in a nested dictionary
static func generate_all_combinations() -> Dictionary:
	var combinations = {}
	for bottle in BottleType.values():
		combinations[bottle] = {}
		for fluid in FluidType.values():
			combinations[bottle][fluid] = PotionData.new(fluid, bottle)
	return combinations

func initialize():
	print("init")
	all_potions = generate_all_combinations()
	InitializeGame.emit(all_potions)
	start_level()
	fade_to_black.fade_from_black(1)

func get_combined_potion_color(potions: Array) -> Color:
	var combined_color = Color(0, 0, 0, 0)
	var color_count = potions.size()

	if color_count == 0:
		return combined_color

	for potion in potions:
		var color = potion.get_color()
		combined_color.r += color.r
		combined_color.g += color.g
		combined_color.b += color.b
		combined_color.a += color.a

	combined_color.r /= color_count
	combined_color.g /= color_count
	combined_color.b /= color_count
	combined_color.a /= color_count

	return combined_color

func _on_AddIngredient(potion: PotionData):
	cauldron_contents.append(potion)
	
	potion.node.can_be_selected = false

	# If the ingredients can make a potion
	if can_mix_ingredients(cauldron_contents):
		var color = get_mix_result(cauldron_contents).get_color()
		change_cauldron_liquid_color(color)
	# If the cauldron was empty
	elif len(cauldron_contents) == 1:
		change_cauldron_liquid_color(potion.get_color())
	else:
		var combined_color = get_combined_potion_color(cauldron_contents)
		change_cauldron_liquid_color(combined_color)

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

func _on_MixIngredients():
	if not cauldron.being_poured_into:
		if can_mix_ingredients(cauldron_contents):
			successful_mix_ingredients()
		else:
			failed_mix_ingredients()
		MixAttempt.emit()

func failed_mix_ingredients():
	while len(cauldron_contents) > 0:
		var potion_from_cauldron = cauldron_contents.pop_front()
		
		potion_from_cauldron.node.position = potion_from_cauldron.position
		potion_from_cauldron.node.can_be_selected = true
		
	change_cauldron_liquid_color(water_color)

func successful_mix_ingredients():
	var resulting_potion = get_mix_result(cauldron_contents)
	for potion in cauldron_contents:
		potion.node.can_be_selected = true
		all_potions[potion.bottle][potion.fluid].reset_values()

	all_potions[resulting_potion.bottle][resulting_potion.fluid].ingredients = []
	resulting_potion.node.can_be_selected = true

	cauldron_contents.clear()

	change_cauldron_liquid_color(resulting_potion.get_color())

	if resulting_potion == required_potion:
		all_potions[resulting_potion.bottle][resulting_potion.fluid].reset_values()
		game_timer.paused = true
		GamePause.emit(true)
		
		FinishedLevel.emit(resulting_potion)
		level += 1
		if level >= len(LEVEL_CONFIG):
			end_game()
		else:
			await delay("time_before_level_transition")
			await fade_in("Starting Level " + str(level+1))
			await fade_pause()
			resulting_potion.node.can_be_selected = true
			resulting_potion.node.global_position = Vector3(1, 1, 1)
			change_cauldron_liquid_color(water_color)
			resulting_potion.clear_values()
			start_level()
			await fade_out()
	else:
		CompletedPotion.emit(resulting_potion)



func end_game():
	await delay("time_before_level_transition")
	await fade_in("You beat the game, wow!")
	await fade_pause()

func set_game_timer(level_config):
	game_timer.wait_time = level_config.game_timer

func start_level():
	set_lantern_values(LEVEL_CONFIG[level])
	set_game_timer(LEVEL_CONFIG[level])
	
	var potion_data = {
		"RED:FLASK": {
			"RED:JUG": null,
			"GREEN:VIAL": {
				"PINK:FLASK": null,
				"BLUE:VIAL": null,
			},
			"BLUE:JUG": null,
		}
	}
	
	required_potion = LEVEL_CONFIG[level]["potion"].call(all_potions)
	required_potion.result = null
	
	var starting_potions = required_potion.get_all_leaves()
	var potion_recipe = required_potion.get_all_non_leaves()

	StartedLevel.emit(starting_potions)
		
	game_timer.start()
	game_timer.paused = false
	GamePause.emit(false)
	Recipe.emit(potion_recipe)
	
func _on_LevelTimer_timeout():
	GameLoss.emit()
	await delay("time_before_level_transition")
	await fade_in("You lost, wow! Click to restart.")
	await fade_pause()

func restart_game():
	get_tree().reload_current_scene()
	await fade_out()

func change_cauldron_liquid_color(color: Color):
	var liquid_CSGCylinder = cauldron.get_child(1)
	var material = liquid_CSGCylinder.material
	
	if tween:
		tween.kill() # Abort the previous animation.
	tween = create_tween()
	tween.tween_property(material, 
					"emission", 
					color,
					1)

func can_mix_ingredients(ingredients: Array) -> bool:
	"""
	Returns true if all of the ingredients have the same root.
	"""
	if len(ingredients) == 0:
		return false

	var first_potion_siblings = ingredients[0].get_siblings()
	return array_contents_equal(first_potion_siblings, ingredients)

func get_mix_result(ingredients: Array):
	return ingredients[0].result

func array_contents_equal(array_1: Array, array_2: Array) -> bool:
	var sorted_array_1 = array_1.duplicate()
	var sorted_array_2 = array_2.duplicate()

	sorted_array_1 = PotionData.sort_potion_data_array(sorted_array_1)
	sorted_array_2 = PotionData.sort_potion_data_array(sorted_array_2)

	return sorted_array_1.hash() == sorted_array_2.hash()

func delay(timer_name: String):
	await get_tree().create_timer(TIMES[timer_name]).timeout

