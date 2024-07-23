extends Node3D

const PotionType = preload("res://Scripts/Utilities/PotionEquation.gd").PotionType

var MAX_POTION_TYPES = 8

var green = PotionEquation.new(PotionType.GREEN, [PotionType.BLUE, PotionType.RED])
var black = PotionEquation.new(PotionType.BLACK, [PotionType.YELLOW, green])

const LEVELS = [
	{"min_top_level_potions": 2, "max_top_level_potions": 3, "min_ingredients_per_potion": 2, "max_ingredients_per_potion": 3, "min_nested": 0, "max_nested": 0, "nest_probability": 0.1},
	{"min_top_level_potions": 3, "max_top_level_potions": 5, "min_ingredients_per_potion": 2, "max_ingredients_per_potion": 5, "min_nested": 1, "max_nested": 2, "nest_probability": 0.5}
]

func get_potion_equations(min_top_level_potions: int, max_top_level_potions: int, min_ingredients_per_potion: int, max_ingredients_per_potion: int, min_nested: int, max_nested: int, nest_probability: float) -> Array:
	var potions = []
	var amount = randi_range(min_top_level_potions, max_top_level_potions)
	for i in range(amount):
		potions.append(generate_potion_equation(min_ingredients_per_potion, max_ingredients_per_potion, min_nested, max_nested, nest_probability))
	return potions

func generate_potion_equation(min_potions: int, max_potions: int, min_nested: int, max_nested: int, nest_probability: float, current_depth: int = 0) -> PotionEquation:
	var potion_type = randi() % MAX_POTION_TYPES
	var num_ingredients = randi_range(min_potions, max_potions)
	var ingredients = []

	while ingredients.size() < num_ingredients:
		if current_depth < max_nested and randf() < nest_probability:  # 50% chance to nest if not at recursion limit
			var nested_potion = generate_potion_equation(min_potions, max_potions, min_nested, max_nested, nest_probability, current_depth + 1)
			if nested_potion.result != potion_type and not nested_potion in ingredients:
				ingredients.append(nested_potion)
		else:
			var ingredient = randi() % MAX_POTION_TYPES
			if ingredient != potion_type and not ingredient in ingredients:
				ingredients.append(ingredient)

	return PotionEquation.new(potion_type, ingredients)

# Called when the node enters the scene tree for the first time.
var called = false
func _ready():
	if not called:
		var potion_equations = callv("get_potion_equations", LEVELS[1].values())
		for pot in potion_equations:
			print(pot)
		called = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
