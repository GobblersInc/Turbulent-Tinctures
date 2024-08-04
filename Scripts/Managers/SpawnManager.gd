extends Node

const FluidType = preload("res://Scripts/Utilities/PotionData.gd").FluidType
const BottleType = preload("res://Scripts/Utilities/PotionData.gd").BottleType

const POTION_SCENES = {
	BottleType.VIAL: "res://Scenes/Models/vial_potion.tscn",
	BottleType.FLASK: "res://Scenes/Models/flask_potion.tscn",
	BottleType.JUG: "res://Scenes/Models/jug_potion.tscn",
}

const BOUNDS = {
	"top": -2.4,
	"bottom": -1.85,
	"left": -1,
	"right": 1.45,
}
const TABLE_HEIGHT = 2.4
const POTION_MIN_DISTANCE_APART = .3

var potions_on_table = []

func _ready():
	print(GameManager.InitializeGame)
	GameManager.InitializeGame.connect(_on_initialize_game)
	GameManager.FinishedLevel.connect(_on_finished_level)
	GameManager.StartedLevel.connect(_on_started_level)
	GameManager.CompletedPotion.connect(_on_completed_potion)
	
	InteractionManager.AddIngredient.connect(_on_AddIngredient)
	
func _on_initialize_game(all_possible_potions):
	print("init")
	load_all_potions(all_possible_potions)
	
func _on_finished_level(resulting_potion):
	spawn_required_potion(resulting_potion)

func _on_started_level(starting_potions):
	potions_on_table = []
	
	for potion in starting_potions:
		spawn_new_potion(potion, starting_potions)
	
func _on_completed_potion(resulting_potion: PotionData):
	spawn_new_potion(resulting_potion, potions_on_table)
	
func _on_AddIngredient(potion_data: PotionData):
	potions_on_table.erase(potion_data)

func load_all_potions(all_potions: Dictionary):
	for bottle in BottleType.values():
		for fluid in FluidType.values():
			spawn_potion(all_potions[bottle][fluid])
			
func spawn_potion(potion: PotionData) -> void:
	"""
	Spawn in a single potion, setting its position, bottle type, and color as defined by the object's fields
	"""
	var bottle_type = potion.bottle
	var potion_node = load(POTION_SCENES[bottle_type]).instantiate()
	add_child(potion_node)

	potion_node.global_position = potion.position
	potion_node.scale = Vector3(.6, .6, .6)
	potion_node.potion_data = potion

	potion.node = potion_node

	change_potion_color(potion)
	
func spawn_required_potion(potion: PotionData):
	potion.position = Vector3(BOUNDS["left"] + .96, TABLE_HEIGHT+1.25, BOUNDS["top"] - .7)
	potion.node.global_position = potion.position
	potion.node.can_be_selected = false
	potion.result = null
	potions_on_table.append(potion)
	
func spawn_new_potion(potion: PotionData, potion_list: Array) -> void:
	var position = get_valid_position(potion_list)
	potion.position = position
	potion.node.global_position = position
	
	potions_on_table.append(potion)
	
func generate_position() -> Vector3:
	var x = randf_range(BOUNDS["left"], BOUNDS["right"])
	var z = randf_range(BOUNDS["bottom"], BOUNDS["top"])
	var position = Vector3(x, TABLE_HEIGHT, z)

	return position
	
func change_potion_color(potion: PotionData) -> void:
	var potion_node = potion.node
	var fluid_mesh_instance = potion_node.find_child("fluid") as MeshInstance3D
	var color = potion.get_color()
	
	# Duplicate the mesh to create a unique instance
	set_mesh_material_emission(fluid_mesh_instance, color)
	
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
