extends Node3D

const POTION_SCENE_PATH = "res://Scenes/Models/potion.tscn"
@onready var ship = $"../.."
const PotionType = preload("res://Scripts/Utilities/PotionData.gd").PotionType

var MAX_POTION_TYPES = 8

var cauldron_contents = []

const LEVELS = [
	{"min_ingredients_per_potion": 2, "max_ingredients_per_potion": 3, "min_nested": 0, "max_nested": 0, "nest_probability": 0.1},
	{"min_ingredients_per_potion": 2, "max_ingredients_per_potion": 5, "min_nested": 1, "max_nested": 2, "nest_probability": 0.5}
]

func generate_potion_equation(min_ingredients_per_potion: int, max_ingredients_per_potion: int, min_nested: int, max_nested: int, nest_probability: float) -> PotionData:
	return _generate_potion_equation(min_ingredients_per_potion, max_ingredients_per_potion, min_nested, max_nested, nest_probability)

func _generate_potion_equation(min_ingredients_per_potion: int, max_ingredients_per_potion: int, min_nested: int, max_nested: int, nest_probability: float, current_depth: int = 0) -> PotionData:
	var potion_type = randi() % MAX_POTION_TYPES
	var num_ingredients = randi_range(min_ingredients_per_potion, max_ingredients_per_potion)
	var ingredients = []

	while ingredients.size() < num_ingredients:
		if current_depth < max_nested and randf() < nest_probability:
			var nested_potion = _generate_potion_equation(min_ingredients_per_potion, max_ingredients_per_potion, min_nested, max_nested, nest_probability, current_depth + 1)
			if nested_potion.type != potion_type and not nested_potion in ingredients:
				ingredients.append(nested_potion)
		else:
			var ingredient_type = randi() % MAX_POTION_TYPES
			if ingredient_type != potion_type and not ingredient_type in ingredients:
				ingredients.append(ingredient_type)

	var potion_equation = PotionData.new(potion_type)
	for ingredient in ingredients:
		if ingredient is PotionData:
			potion_equation.add_child(ingredient)
		else:
			potion_equation.add_child(PotionData.new(ingredient))
	return potion_equation

# Called when the node enters the scene tree for the first time.
var called = false
func _ready():
	if not called:
		#var green = PotionData.new(PotionType.GREEN)
		#green.add_child(PotionData.new(PotionType.BLUE))
		#green.add_child(PotionData.new(PotionType.RED))
#
		#var black = PotionData.new(PotionType.BLACK)
		#black.add_child(PotionData.new(PotionType.YELLOW))
		#black.add_child(green)
		
		#print(black)
		
		#var potion_equation = generate_potion_equation(LEVELS[1].min_ingredients_per_potion, LEVELS[1].max_ingredients_per_potion, LEVELS[1].min_nested, LEVELS[1].max_nested, LEVELS[1].nest_probability)
		#print(potion_equation)
		
		var blue = PotionData.new(PotionType.BLUE)
		var red = PotionData.new(PotionType.RED)
		
		var purple = PotionData.new(PotionType.PURPLE)
		purple.add_child(blue)
		purple.add_child(red)
		cauldron_contents.append(blue)
		cauldron_contents.append(red)
		
		print(try_mix_ingredients(cauldron_contents))
		
		load_potion_nodes()
		
		called = true

func load_potion_nodes() -> void:
	var potion_scene = load(POTION_SCENE_PATH).instantiate()
	ship.add_child(potion_scene)
	potion_scene.global_transform.origin = Vector3(2.31, 0, 0)

func add_to_cauldron():
	
	pass

func try_mix_ingredients(ingredients: Array) -> PotionData:
	if can_mix_ingredients(ingredients):
		return get_mix_result(ingredients)
		
	return null

func can_mix_ingredients(ingredients: Array) -> bool:
	var first_potion_siblings = ingredients[0].get_siblings()
	return array_contents_equal(first_potion_siblings, ingredients)
	
func get_mix_result(ingredients: Array):
	return ingredients[0].result
	
func array_contents_equal(array_1: Array, array_2: Array) -> bool:
	var sorted_array_1 = array_1.duplicate()
	var sorted_array_2 = array_2.duplicate()
	
	sorted_array_1.sort()
	sorted_array_2.sort()
	
	return sorted_array_1.hash() == sorted_array_2.hash()

func can_combine(potion_1, potion_2) -> bool:
	return potion_1 in potion_2.get_siblings()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
