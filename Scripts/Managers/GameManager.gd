extends Node3D

const POTION_SCENE_PATH = "res://Scenes/Models/potion.tscn"
@onready var ship = $"../.."
const PotionType = preload("res://Scripts/Utilities/PotionData.gd").PotionType

var MAX_POTION_TYPES = PotionType.size()

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
		var required_potion = generate_potion_equation(LEVELS[0].min_ingredients_per_potion, LEVELS[0].max_ingredients_per_potion, LEVELS[0].min_nested, LEVELS[0].max_nested, LEVELS[0].nest_probability)

		var starting_potions = required_potion.get_all_leaves()

		load_potion_nodes(starting_potions)

		print("Potion to make: ", required_potion)

		for potion in starting_potions:
			change_potion_color(potion)

		called = true

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


func load_potion_nodes(potions_list: Array) -> void:
	var BOUNDS = {
		"top": -2.735,
		"bottom": -1.85,
		"left": -1,
		"right": 1.45,
	}
	
	const TABLE_HEIGHT = 2.4
	
	var potion_positions = []
	while potion_positions.size() < len(potions_list):
		var x = randf_range(BOUNDS["left"], BOUNDS["right"])
		var z = randf_range(BOUNDS["bottom"], BOUNDS["top"])
		var position = Vector3(x, TABLE_HEIGHT, z)

		if is_position_valid(position, potion_positions):
			potion_positions.append(position)

	for i in range(len(potions_list)):
		var potion_node = load(POTION_SCENE_PATH).instantiate()
		add_child(potion_node)
		potion_node.global_position = potion_positions[i]
		potion_node.scale = Vector3(1, 1, 1)
		
		potions_list[i].node = potion_node

func is_position_valid(position: Vector3, positions: Array) -> bool:
	"""
	This could almost certainly be done a better way - this way, the outer function runs at O(n^2)
	"""
	const POTION_MIN_DISTANCE_APART = .2
	
	for existing_position in positions:
		if position.distance_to(existing_position) < POTION_MIN_DISTANCE_APART:
			return false
	return true

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
