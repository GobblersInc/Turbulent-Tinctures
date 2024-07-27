extends Node3D

@onready var movement_manager = $"../MovementManager"
@onready var ship = $"../.."

var PotionGeneration = preload("res://Scripts/Utilities/PotionGeneration.gd").new()

const FluidType = preload("res://Scripts/Utilities/PotionData.gd").FluidType
const BottleType = preload("res://Scripts/Utilities/PotionData.gd").BottleType
const POTION_SCENES = {
	BottleType.VIAL: "res://Scenes/Models/vial_potion.tscn",
	BottleType.FLASK: "res://Scenes/Models/flask_potion.tscn",
	BottleType.JUG: "res://Scenes/Models/jug_potion.tscn",
}

const POTION_MIN_DISTANCE_APART = .4
const TABLE_HEIGHT = 2.4
const BOUNDS = {
	"top": -2.7,
	"bottom": -1.85,
	"left": -1,
	"right": 1.45,
}


var potions_on_table = []
var cauldron_contents = []
var required_potion = null
var level = 0

"""
The minimum nesting one can do is 1 - otherwise there wouldn't be any potion equations!
"""
var LEVELS = [
	{"ingredients_per_potion": MinMax.new(1, 1), "times_nested": MinMax.new(1, 1), "nest_probability": 0},
	{"ingredients_per_potion": MinMax.new(1, 1), "times_nested": MinMax.new(2, 2), "nest_probability": 0.3},
]


func _ready():
	initialize()
	
	movement_manager.AddIngredient.connect(_on_AddIngredient)
	movement_manager.MixIngredients.connect(_on_MixIngredients)
	
func initialize():
	start_level()

func _on_AddIngredient(potion: PotionData):
	cauldron_contents.append(potion)
	potions_on_table.erase(potion)

func _on_MixIngredients():
	if can_mix_ingredients(cauldron_contents):
		var resulting_potion = get_mix_result(cauldron_contents)
		spawn_new_potion(resulting_potion, potions_on_table)
		
		cauldron_contents.clear()
		if resulting_potion == required_potion:
			level += 1
			await get_tree().create_timer(2.0).timeout
			
			resulting_potion.node.queue_free()
			start_level()
	else:
		while len(cauldron_contents) > 0:
			var potion_from_cauldron = cauldron_contents.pop_front()
			spawn_potion(potion_from_cauldron)

func start_level():
	if level >= len(LEVELS):
		print("You beat the game, wow!")
		return
		
	potions_on_table = []
	required_potion = PotionGeneration.generate_potion_equation(LEVELS[level])
	
	print("Level ", level)
	print("-------------------------")
	required_potion.print_game_info(false)

	var starting_potions = required_potion.get_all_leaves()

	for potion in starting_potions:
		spawn_new_potion(potion, starting_potions)

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
