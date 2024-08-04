extends Node

const FluidType = preload("res://Scripts/Utilities/PotionData.gd").FluidType
const BottleType = preload("res://Scripts/Utilities/PotionData.gd").BottleType
@onready var cauldron = get_node("/root/PirateShip/Cauldron")

const BOUNDS = {
	"top": -2.4,
	"bottom": -1.85,
	"left": -1,
	"right": 1.45,
}
const POTION_SCALE = Vector3(.8, .8, .8)
const TABLE_HEIGHT = 2.4
const POTION_MIN_DISTANCE_APART = .3

var potions_on_table = []

func _ready():
	LevelManager.PreparedLevel.connect(_on_prepared_level)
	cauldron.CompletedPotion.connect(_on_completed_potion)
	cauldron.FailedMix.connect(_on_failed_mix)
	
	InteractionManager.AddIngredient.connect(_on_add_ingredient)
	
func _on_prepared_level(starting_potions, required_potion):
	potions_on_table = []

	for potion in starting_potions:
		spawn_new_potion(potion, starting_potions)
	
func _on_completed_potion(resulting_potion: PotionData, is_final_potion):
	if is_final_potion:
		spawn_required_potion(resulting_potion)
		resulting_potion.clear_values()
	else:
		spawn_new_potion(resulting_potion, potions_on_table)

func _on_failed_mix(cauldron_contents):
	# Clear everything in the cauldron
	for potion in cauldron_contents:
		potion.node.position = potion.position
		potion.node.remove_potion_outline()
		potion.node.scale = POTION_SCALE
		potion.node.can_be_selected = true
		
	cauldron_contents.clear()
	
func _on_add_ingredient(potion_data: PotionData):
	potions_on_table.erase(potion_data)
	
func spawn_required_potion(potion: PotionData):
	var pos = Vector3(BOUNDS["left"] + .96, TABLE_HEIGHT+1.15, BOUNDS["top"] - .7)
	potion.node.position = pos
	potion.node.can_be_selected = false
	potion.result = null
	potions_on_table.append(potion)
	
func spawn_new_potion(potion: PotionData, potion_list: Array) -> void:
	change_potion_color(potion)	
	
	var position = get_valid_position(potion_list)
	potion.position = position
	potion.node.scale = POTION_SCALE
	potion.node.remove_potion_outline()
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
