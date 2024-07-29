extends Node3D 

@onready var input_manager = $"../InputManager"

signal AddIngredient(potion)
signal MixIngredients()

var selection_mesh: MeshInstance3D = null
const OUTLINE_MATERIAL_PATH = "res://Resources/Materials/Outline.tres"

var selected_potion = null

func _ready():
	input_manager.ObjectClicked.connect(_on_ObjectClicked)

func _on_ObjectClicked(_event_position, object_info):
	var player_clicked_cauldron = object_info.is_in_group("cauldron")
	var player_clicked_potion = object_info.is_in_group("potion")
	var object = object_info.get_parent().get_parent()

	if player_clicked_cauldron:
		clicking_cauldron(object)
	elif player_clicked_potion:
		clicking_potion(object)
		
func clicking_cauldron(cauldron: Node3D):
	if selected_potion:
		var containers_are_available = not (selected_potion.pouring or cauldron.being_poured_into)
		if containers_are_available:
			selected_potion.pour_potion(cauldron)
			remove_selection_outline(selected_potion)
			AddIngredient.emit(selected_potion.potion_data)
			
			selected_potion = null
	else:
		MixIngredients.emit()
		


func clicking_potion(potion: Node3D):
	if not potion.can_be_selected:
		return
	
	if selected_potion:
		remove_selection_outline(selected_potion)
		selected_potion = null
	# There isn't a potion selected
	else:
		SoundManager.play_random_potion_interact_sound()
		selected_potion = potion
		
		if selection_mesh == null:
			add_selection_outline(selected_potion)
		else:
			remove_selection_outline(selected_potion)


func add_selection_outline(potion: Node3D) -> void:
	# Get the MeshInstance3D from the potion node
	var mesh_instance: MeshInstance3D = potion.get_child(0).get_child(0).get_child(0)
	
	# Duplicate the current mesh to ensure we are not modifying a shared mesh
	var duplicated_mesh: ArrayMesh = mesh_instance.mesh.duplicate()
	
	# Get the original material from the duplicated mesh
	var original_material: Material = duplicated_mesh.surface_get_material(0)
	
	# Duplicate the original material to create a unique copy
	var potion_outline_material: Material = original_material.duplicate()
	
	# Modify the duplicated material for the outline effect
	potion_outline_material.emission_enabled = true
	potion_outline_material.emission = Color(1, 1, 1)
	potion_outline_material.emission_energy = .7
	
	# Assign the duplicated material to the duplicated mesh
	duplicated_mesh.surface_set_material(0, potion_outline_material)
	
	# Assign the duplicated mesh to the mesh_instance
	mesh_instance.mesh = duplicated_mesh
	
	# Store the duplicated material in the potion node for later reference (e.g., removing the outline)
	potion.set_meta("outline_material", potion_outline_material)
	potion.set_meta("original_material", original_material)
	potion.set_meta("original_mesh", mesh_instance.mesh)


func remove_selection_outline(potion: Node3D) -> void:
	# Get the MeshInstance3D from the potion node
	var mesh_instance: MeshInstance3D = potion.get_child(0).get_child(0).get_child(0)
	
	# Retrieve the original material and mesh from the potion node's metadata
	var original_material: Material = potion.get_meta("original_material")
	var outline_material: Material = potion.get_meta("outline_material")
	var original_mesh: ArrayMesh = potion.get_meta("original_mesh")
	
	if outline_material:
		outline_material.emission_enabled = false
		
		# Restore the original material and mesh to the mesh_instance
		mesh_instance.mesh.surface_set_material(0, original_material)
		mesh_instance.mesh = original_mesh
		
		# Clear the metadata
		potion.set_meta("outline_material", null)
		potion.set_meta("original_material", null)
		potion.set_meta("original_mesh", null)
