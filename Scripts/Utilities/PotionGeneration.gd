extends Resource

const FluidType = preload("res://Scripts/Utilities/PotionData.gd").FluidType
const BottleType = preload("res://Scripts/Utilities/PotionData.gd").BottleType

var MAX_FLUID_TYPES = FluidType.size()
var MAX_BOTTLE_TYPES = BottleType.size()

func generate_potion_equation(level_config: Dictionary, parent_potion=null, current_depth: int = 0) -> PotionData:
	var potion = generate_unique_potion(parent_potion)

	var num_ingredients = randi_range(level_config.ingredients_per_potion.min, level_config.ingredients_per_potion.max)
	while potion.ingredients.size() < num_ingredients:
		var should_nest = current_depth < level_config.times_nested.max and randf() < level_config.nest_probability
		var new_potion
		new_potion = generate_potion_equation(level_config, potion, current_depth + 1) if should_nest else generate_unique_potion(potion)
		potion.add_ingredient(new_potion)

	return potion
	
func generate_random_potion():
	var fluid = randi() % MAX_FLUID_TYPES
	var bottle = randi() % MAX_BOTTLE_TYPES
	return PotionData.new(fluid, bottle)

func generate_unique_potion(parent_potion: PotionData = null) -> PotionData:
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
