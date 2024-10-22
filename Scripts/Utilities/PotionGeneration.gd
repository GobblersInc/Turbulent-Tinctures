extends Resource

const FluidType = preload("res://Scripts/Utilities/PotionData.gd").FluidType
const BottleType = preload("res://Scripts/Utilities/PotionData.gd").BottleType

var MAX_FLUID_TYPES = FluidType.size()
var MAX_BOTTLE_TYPES = BottleType.size()

# Function to generate a potion equation with unique potions
func generate_potion_equation(level_config: Dictionary, parent_potion=null, current_depth: int = 0, used_combinations = null) -> PotionData:
	if used_combinations == null:
		used_combinations = []
	
	var result = generate_unique_potion(used_combinations)
	var potion = result[0]
	used_combinations = result[1]

	var num_ingredients = randi_range(level_config.ingredients_per_potion.min, level_config.ingredients_per_potion.max)
	while potion.ingredients.size() < num_ingredients:
		var should_nest = current_depth < level_config.times_nested.max - 2 and randf() < level_config.nest_probability
		var new_potion
		if should_nest:
			new_potion = generate_potion_equation(level_config, potion, current_depth + 1, used_combinations) 
		else:
			result = generate_unique_potion(used_combinations)
			new_potion = result[0]
			used_combinations = result[1]
		potion.add_ingredient(new_potion)

	return potion

func generate_unique_potion(used_combinations: Array):
	while true:
		var fluid = randi() % MAX_FLUID_TYPES
		var bottle = randi() % MAX_BOTTLE_TYPES
		var combination = [bottle, fluid]

		if combination not in used_combinations:
			used_combinations.append(combination)
			return [PotionData.new(fluid, bottle), used_combinations]

func generate_random_potion():
	var fluid = randi() % MAX_FLUID_TYPES
	var bottle = randi() % MAX_BOTTLE_TYPES
	return PotionData.new(fluid, bottle)

func _generate_unique_potion(parent_potion: PotionData = null) -> PotionData:
	"""
	Keeps generating new potions until it finds one that is a "unique ingredient"
	"""
	if parent_potion == null:
		return generate_random_potion()

	var is_unique_ingredient = false
	var potion
	
	while not is_unique_ingredient:
		potion = generate_random_potion()
		is_unique_ingredient = is_unique_ingredient(parent_potion, potion)
	
	return potion
	
func is_unique_ingredient(parent_potion: PotionData, nested_potion: PotionData) -> bool:
	"""
	Ensure that:
		1. The fluid and bottle type is different than the parent
		2. The fluid and bottle type is different than any of the ingredients
	"""
	var is_different_from_parent = are_potions_unique(parent_potion, nested_potion)
	
	var is_unique_ingredient = true
	for potion in parent_potion.ingredients:
		if not are_potions_unique(potion, nested_potion):
			is_unique_ingredient
			
	return is_unique_ingredient
	
func are_potions_unique(potion_1, potion_2):
	var is_unique_bottle = potion_1.bottle != potion_2.bottle
	var is_unique_fluid = potion_1.fluid != potion_2.fluid
	
	return is_unique_bottle and is_unique_fluid
