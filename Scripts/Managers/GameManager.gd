extends Node3D

@onready var movement_manager = $"../MovementManager"
@onready var ship = $"../.."

const TABLE_HEIGHT = 2.4
const BOUNDS = {
	"top": -2.7,
	"bottom": -1.85,
	"left": -1,
	"right": 1.45,
}
const POTION_MIN_DISTANCE_APART = .4

const FluidType = preload("res://Scripts/Utilities/PotionData.gd").FluidType
const BottleType = preload("res://Scripts/Utilities/PotionData.gd").BottleType

const POTION_SCENES = {
	BottleType.VIAL: "res://Scenes/Models/vial_potion.tscn",
	BottleType.FLASK: "res://Scenes/Models/flask_potion.tscn",
	BottleType.JUG: "res://Scenes/Models/jug_potion.tscn",
}

var MAX_FLUID_TYPES = FluidType.size()
var MAX_BOTTLE_TYPES = BottleType.size()

var potions_on_table = [] # this should update as the game does
var cauldron_contents = []
var required_potion = null

var level = 1

const LEVELS = [
	{"min_ingredients_per_potion": 2, "max_ingredients_per_potion": 3, "min_nested": 0, "max_nested": 0, "nest_probability": 0.1},
	{"min_ingredients_per_potion": 3, "max_ingredients_per_potion": 5, "min_nested": 3, "max_nested": 3, "nest_probability": 1}
]


func generate_potion_equation(min_ingredients_per_potion: int, max_ingredients_per_potion: int, min_nested: int, max_nested: int, nest_probability: float) -> PotionData:
	return _generate_potion_equation(min_ingredients_per_potion, max_ingredients_per_potion, min_nested, max_nested, nest_probability)

func _generate_potion_equation(min_ingredients_per_potion: int, max_ingredients_per_potion: int, min_nested: int, max_nested: int, nest_probability: float, current_depth: int = 0) -> PotionData:
	var fluid_type = randi() % MAX_FLUID_TYPES
	var bottle_type = randi() % MAX_BOTTLE_TYPES
	
	var num_ingredients = randi_range(min_ingredients_per_potion, max_ingredients_per_potion)
	var ingredients = []

	while ingredients.size() < num_ingredients:
		if current_depth < max_nested and randf() < nest_probability:
			var nested_potion = _generate_potion_equation(min_ingredients_per_potion, max_ingredients_per_potion, min_nested, max_nested, nest_probability, current_depth + 1)
			if nested_potion.fluid != fluid_type and nested_potion.bottle != bottle_type and not nested_potion in ingredients:
				ingredients.append([nested_potion.fluid, nested_potion.bottle])
		else:
			var ingredient_fluid_type = randi() % MAX_FLUID_TYPES
			var ingredient_bottle_type = randi() % MAX_BOTTLE_TYPES
			if ingredient_fluid_type != fluid_type and ingredient_bottle_type != bottle_type and not ingredient_fluid_type in ingredients:
				ingredients.append([ingredient_fluid_type, ingredient_bottle_type])

	var potion_equation = PotionData.new(fluid_type, bottle_type)
	for ingredient in ingredients:
		potion_equation.add_child(PotionData.new(ingredient[0], ingredient[1]))

	return potion_equation

func _ready():
	initialize()
	
	movement_manager.AddIngredient.connect(_on_AddIngredient)
	movement_manager.MixIngredients.connect(_on_MixIngredients)
	
func initialize():
	start_level()

func _on_AddIngredient(potion: PotionData):
	add_to_cauldron(potion)
	potions_on_table.erase(potion)
	print("potions_on_table", potions_on_table)
	print("cauldron_contents", cauldron_contents)

func _on_MixIngredients():
	if can_mix_ingredients(cauldron_contents):
		var resulting_potion = get_mix_result(cauldron_contents)
		if resulting_potion == required_potion:
			level += 1
			start_level()
		else:
			spawn_new_potion(resulting_potion, potions_on_table)
		cauldron_contents.clear()
	else:
		while len(cauldron_contents) > 0:
			var destroyed_potion = cauldron_contents.pop_front()
			spawn_potion(destroyed_potion)
		
	print("potions_on_table", potions_on_table)
	print("cauldron_contents", cauldron_contents)

func start_level():
	if level >= len(LEVELS):
		print("You beat the game, wow!")
		return
	
	potions_on_table = []
	required_potion = generate_potion_equation(LEVELS[level].min_ingredients_per_potion, LEVELS[level].max_ingredients_per_potion, LEVELS[level].min_nested, LEVELS[level].max_nested, LEVELS[level].nest_probability)

	print(required_potion.gathering_stats(0, null))

	var starting_potions = required_potion.get_all_leaves()

	print("Potion to make: ", required_potion)

	for potion in starting_potions:
		spawn_new_potion(potion, starting_potions)

func spawn_new_potion(potion: PotionData, potion_list: Array) -> void:
	var position = get_valid_position(potion_list)
	potion.position = position
	spawn_potion(potion)
	potions_on_table.append(potion)

func change_potion_color(potion: PotionData) -> void:
	var potion_node = potion.node
	var fluid_mesh_instance = potion_node.get_child(0).get_child(2) as MeshInstance3D
	
	# Duplicate the mesh to create a unique instance
	var original_mesh = fluid_mesh_instance.mesh
	var new_mesh = original_mesh.duplicate() as ArrayMesh
	
	# Apply the new mesh to the mesh instance
	fluid_mesh_instance.mesh = new_mesh
	
	# Duplicate the material to create a unique instance
	var original_material = new_mesh.surface_get_material(0)
	var fluid_material = original_material.duplicate()
	
	# Apply the duplicated material to the new mesh
	new_mesh.surface_set_material(0, fluid_material)
	
	# Change the color of the duplicated material
	var color = potion.get_color()
	fluid_material.set_emission(color)

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


func spawn_potion(potion: PotionData) -> void:
	"""https://github.com/GobblersInc/Turbulent-Tinctures/pull/72
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


func add_to_cauldron(potion: PotionData) -> void:
	"""
	Add to the cauldron list list.
	"""
	cauldron_contents.append(potion)

func can_mix_ingredients(ingredients: Array) -> bool:
	"""
	Returns true if all of the ingredients have the same root.
	"""
	if len(ingredients) == 0:
		return false

	var first_potion_siblings = ingredients[0].get_siblings()
	print("first_potion_siblings", first_potion_siblings)
	print("ingredients", ingredients)
	return array_contents_equal(first_potion_siblings, ingredients)
	
func get_mix_result(ingredients: Array):
	return ingredients[0].result
	
func array_contents_equal(array_1: Array, array_2: Array) -> bool:
	var sorted_array_1 = array_1.duplicate()
	var sorted_array_2 = array_2.duplicate()
	
	sorted_array_1 = PotionData.sort_potion_data_array(sorted_array_1)
	sorted_array_2 = PotionData.sort_potion_data_array(sorted_array_2)
	
	print(sorted_array_1)
	print(sorted_array_2)
	
	return sorted_array_1.hash() == sorted_array_2.hash()

func can_combine(potion_1, potion_2) -> bool:
	return potion_1 in potion_2.get_siblings()
