extends Node3D

@onready var lantern = $"../Lantern"

var being_poured_into = false
var selected = false
var tween: Tween


const water_color = Color(0.064, 0.142, 0.482)

signal DonePouring
signal CompletedPotion(resulting_potion: PotionData, is_final_potion: bool)
signal LanternUpdated()

var cauldron_contents = []
var required_potion: PotionData = null

func is_disabled():
	return being_poured_into

# Called when the node enters the scene tree for the first time.
func _ready():
	lantern.LightOff.connect(_lantern_light_off)
	lantern.LightOn.connect(_lantern_light_on)
	SoundManager.play_boiling_water_sound()

	InteractionManager.AddIngredient.connect(_on_AddIngredient)
	InteractionManager.MixIngredients.connect(_on_MixIngredients)
	
		
func _on_MixIngredients():
	if not being_poured_into:
		if can_mix_ingredients(cauldron_contents):
			successful_mix_ingredients()
		else:
			failed_mix_ingredients()

func _on_AddIngredient(potion):
	cauldron_contents.append(potion)

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
		
func failed_mix_ingredients():
	# Clear everything in the cauldron
	while len(cauldron_contents) > 0:
		var potion_from_cauldron = cauldron_contents.pop_front()
		
		potion_from_cauldron.node.position = potion_from_cauldron.position
		potion_from_cauldron.node.can_be_selected = true
		
	change_cauldron_liquid_color(water_color)
	
func successful_mix_ingredients():
	var resulting_potion = get_mix_result(cauldron_contents)
	for potion in cauldron_contents:
		potion.node.can_be_selected = true
		potion.reset_values
		#LevelConfig.all_potions[potion.bottle][potion.fluid].reset_values()

	#all_potions[resulting_potion.bottle][resulting_potion.fluid].ingredients = []
	resulting_potion.ingredients = []
	resulting_potion.node.can_be_selected = true

	cauldron_contents.clear()
	change_cauldron_liquid_color(resulting_potion.get_color())

	if resulting_potion == LevelManager.required_potion:
		CompletedPotion.emit(resulting_potion, true)
	else:
		CompletedPotion.emit(resulting_potion, false)

func _lantern_light_off():
	_set_cauldron_emission(true)
	
func _lantern_light_on():
	_set_cauldron_emission(false)
	
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

func _set_cauldron_emission(enabled: bool):
	var cauldron_mesh: ArrayMesh = get_child(0).get_child(0).mesh
	for i in range(cauldron_mesh.get_surface_count()):
		var material: StandardMaterial3D = cauldron_mesh.surface_get_material(i)
		if material:
			if enabled:
				material.emission_enabled = true
				material.emission = Color(0.041, 0, 0.113)
				material.emission_energy = .5
			else:
				material.emission_enabled = false

func change_cauldron_liquid_color(color: Color):
	var liquid_CSGCylinder = get_child(1)
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
	return ingredients_list_equal(first_potion_siblings, ingredients)

func ingredients_list_equal(ingredients_1: Array, ingredients_2: Array) -> bool:
	var sorted_ingredients_1 = ingredients_1.duplicate()
	var sorted_ingredients_2 = ingredients_2.duplicate()

	sorted_ingredients_1 = PotionData.sort_potion_data_array(sorted_ingredients_1)
	sorted_ingredients_2 = PotionData.sort_potion_data_array(sorted_ingredients_2)

	return sorted_ingredients_1.hash() == sorted_ingredients_2.hash()

func get_mix_result(ingredients: Array):
	return ingredients[0].result

