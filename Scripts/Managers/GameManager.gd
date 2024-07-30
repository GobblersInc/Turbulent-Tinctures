extends Node3D

@onready var movement_manager = $"../MovementManager"
@onready var input_manager = $"../InputManager"
@onready var ship = $"../.."
@onready var fade_to_black = $"../../WorldEnvironment/FadeToBlack"
@onready var popup_text = $"../../CanvasLayer/PopupTextFade"
@onready var lantern = $"../../Lantern"
@onready var cauldron = $"../../Cauldron"
@onready var game_timer = $Timer
@onready var timer_fade = $"../../CanvasLayer/TimeLeftFade"

const FluidType = preload("res://Scripts/Utilities/PotionData.gd").FluidType
const BottleType = preload("res://Scripts/Utilities/PotionData.gd").BottleType
const LANTERN_SCRIPT_PATH = "res://Scripts/Models/LanternScript.gd"
const LANTERN_SCENE = "res://Scenes/Models/lantern.tscn"

const water_color = Color(0.064, 0.142, 0.482)

const POTION_SCENES = {
	BottleType.VIAL: "res://Scenes/Models/vial_potion.tscn",
	BottleType.FLASK: "res://Scenes/Models/flask_potion.tscn",
	BottleType.JUG: "res://Scenes/Models/jug_potion.tscn",
}

const POTION_MIN_DISTANCE_APART = .4
const TABLE_HEIGHT = 2.4
const BOUNDS = {
	"top": -2.4,
	"bottom": -1.85,
	"left": -1,
	"right": 1.45,
}

const TIMES = {
	"time_before_level_transition": 0.5,
	"fading_in": 1,
	"pause_to_read_text": 1,
	"fading_out": 1,
	"waiting_for_reload": 0.1
}

var potions_on_table = []
var cauldron_contents = []
var required_potion = null
var level = 0
var lost = false
var pouring = false

signal Recipe(potion_recipe: Array)
signal GameLoss()
signal GamePause(is_paused: bool)
signal MixAttempt()
signal LanternUpdated()

"""
The minimum nesting one can do is 1 - otherwise there wouldn't be any potion equations!
"""
var LEVEL_CONFIG = [
	{
		"potion": level_one_potion,
		"flicker_probability": 1,
		"light_out_duration": 5,
		"check_interval": 5,
		"lights_out_cooldown": 5,
		"light_on_or_off": true,
	},
	{
		"potion": level_two_potion,		
		"flicker_probability": 0.3,
		"light_out_duration": 8,
		"check_interval": 3,
		"lights_out_cooldown": 6,
		"light_on_or_off": true,
	},
]

func set_lantern_values(level_config):

	lantern.flicker_probability = level_config.flicker_probability
	lantern.light_out_duration = level_config.light_out_duration
	lantern.check_interval = level_config.check_interval
	lantern.lights_out_cooldown = level_config.lights_out_cooldown
	lantern.light_on_or_off = level_config.light_on_or_off
	LanternUpdated.emit()

func _ready():
	var target_script = preload("res://Scripts/Utilities/LevelHelper.gd").new()
	target_script._ready()
	
	initialize()
	
	movement_manager.AddIngredient.connect(_on_AddIngredient)
	movement_manager.MixIngredients.connect(_on_MixIngredients)
	
	game_timer.TimeOut.connect(_on_LevelTimer_timeout)
	input_manager.ClickAfterGameLoss.connect(_on_LossClick)
		
func _on_LossClick():
	restart_game()
	


func initialize():
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
	potions_on_table.erase(potion)
	
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
		spawn_potion(potion_from_cauldron)
		
	change_cauldron_liquid_color(water_color)

func successful_mix_ingredients():
	var resulting_potion = get_mix_result(cauldron_contents)
	cauldron_contents.clear()

	change_cauldron_liquid_color(resulting_potion.get_color())

	if resulting_potion == required_potion:
		game_timer.paused = true
		GamePause.emit(true)
		
		spawn_required_potion(resulting_potion)
		level += 1
		if level >= len(LEVEL_CONFIG):
			end_game()
		else:
			await delay("time_before_level_transition")
			await fade_in("Starting Level " + str(level+1))
			await fade_pause()
			resulting_potion.node.queue_free()
			change_cauldron_liquid_color(water_color)
			start_level()
			await fade_out()
	else:
		spawn_new_potion(resulting_potion, potions_on_table)

func end_game():
	await delay("time_before_level_transition")
	await fade_in("You beat the game, wow!")
	await fade_pause()
	
func level_two_potion():
	var root_potion = PotionData.new(PotionData.FluidType.RED, PotionData.BottleType.FLASK)
	var potion_1 = PotionData.new(PotionData.FluidType.RED, PotionData.BottleType.JUG)
	root_potion.add_ingredient(potion_1)
	var potion_2 = PotionData.new(PotionData.FluidType.GREEN, PotionData.BottleType.VIAL)
	root_potion.add_ingredient(potion_2)
	var potion_3 = PotionData.new(PotionData.FluidType.PINK, PotionData.BottleType.FLASK)
	potion_2.add_ingredient(potion_3)
	var potion_4 = PotionData.new(PotionData.FluidType.BLUE, PotionData.BottleType.VIAL)
	potion_2.add_ingredient(potion_4)
	var potion_5 = PotionData.new(PotionData.FluidType.BLUE, PotionData.BottleType.JUG)
	root_potion.add_ingredient(potion_5)
	
	return root_potion
	
func level_one_potion():
	var root_potion = PotionData.new(PotionData.FluidType.RED, PotionData.BottleType.FLASK)
	var potion_1 = PotionData.new(PotionData.FluidType.RED, PotionData.BottleType.JUG)
	root_potion.add_ingredient(potion_1)
	var potion_2 = PotionData.new(PotionData.FluidType.GREEN, PotionData.BottleType.VIAL)
	root_potion.add_ingredient(potion_2)
	var potion_3 = PotionData.new(PotionData.FluidType.PINK, PotionData.BottleType.FLASK)
	potion_2.add_ingredient(potion_3)
	var potion_4 = PotionData.new(PotionData.FluidType.BLUE, PotionData.BottleType.VIAL)
	potion_2.add_ingredient(potion_4)
	var potion_5 = PotionData.new(PotionData.FluidType.BLUE, PotionData.BottleType.JUG)
	root_potion.add_ingredient(potion_5)
	
	return root_potion


	
func start_level():
	set_lantern_values(LEVEL_CONFIG[level])
	potions_on_table = []
	
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
	
	required_potion = LEVEL_CONFIG[level]["potion"].call()
	required_potion.print_game_info(false)
	
	var starting_potions = required_potion.get_all_leaves()
	var potion_recipe = required_potion.get_all_non_leaves()

	for potion in starting_potions:
		spawn_new_potion(potion, starting_potions)
		
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
	
	#await fade_out()

func spawn_potion(potion: PotionData) -> void:
	"""
	Spawn in a single potion, setting its position, bottle type, and color as defined by the object's fields
	"""
	var bottle_type = potion.bottle
	var potion_node = load(POTION_SCENES[bottle_type]).instantiate()
	add_child(potion_node)

	potion_node.global_position = potion.position
	potion_node.scale = Vector3(1, 1, 1)
	potion_node.potion_data = potion

	potion.node = potion_node

	change_potion_color(potion)

func spawn_required_potion(potion: PotionData):
	potion.position = Vector3(BOUNDS["left"] + .96, TABLE_HEIGHT+1.25, BOUNDS["top"] - .7)
	spawn_potion(potion)
	potion.node.can_be_selected = false
	potions_on_table.append(potion)

func spawn_new_potion(potion: PotionData, potion_list: Array) -> void:
	var position = get_valid_position(potion_list)
	potion.position = position
	spawn_potion(potion)
	potions_on_table.append(potion)

func set_mesh_material_emission(mesh_instance: MeshInstance3D, color):
	# Duplicate the mesh to create a unique instance
	var original_mesh = mesh_instance.mesh
	var new_mesh = original_mesh.duplicate() as ArrayMesh

	# Apply the new mesh to the mesh instance
	mesh_instance.mesh = new_mesh

	# Duplicate the material to create a unique instance
	var original_material = new_mesh.surface_get_material(0)
	var new_material = original_material.duplicate()

	# Apply the duplicated material to the new mesh
	new_mesh.surface_set_material(0, new_material)

	# Change the color of the duplicated material
	new_material.set_emission(color)

func change_cauldron_liquid_color(color: Color):
	var liquid_CSGCylinder = cauldron.get_child(1)
	var material = liquid_CSGCylinder.material
	
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(material, 
					"emission", 
					color,
					1)

func change_potion_color(potion: PotionData) -> void:
	var potion_node = potion.node
	var fluid_mesh_instance = potion_node.get_child(0).get_child(2) as MeshInstance3D
	var color = potion.get_color()	
	
	# Duplicate the mesh to create a unique instance
	set_mesh_material_emission(fluid_mesh_instance, color)

func generate_position() -> Vector3:
	var x = randf_range(BOUNDS["left"], BOUNDS["right"])
	var z = randf_range(BOUNDS["bottom"], BOUNDS["top"])
	var position = Vector3(x, TABLE_HEIGHT, z)

	return position

func get_valid_position(potions: Array) -> Vector3:
	var valid = false
	var new_position
	while not valid:
		new_position = generate_position()
		valid = is_position_valid(new_position, potions)

	return new_position

func is_position_valid(position: Vector3, potions: Array) -> bool:
	"""
	This could almost certainly be done a better way - this way, the outer function runs at O(n^2)
	"""
	for potion in potions:
		if position.distance_to(potion.position) < POTION_MIN_DISTANCE_APART:
			return false
	return true

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
