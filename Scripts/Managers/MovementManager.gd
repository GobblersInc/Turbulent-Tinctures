extends Node3D 

const EXTRA_POTION_HEIGHT = 1.2
const POUR_TIME_SECONDS = 1
var selection_mesh: MeshInstance3D = null
const OUTLINE_MATERIAL_PATH = "res://Resources/Materials/Outline.tres"

@onready var input_manager = $"../InputManager"

var selected_potion = null

func _ready():
	input_manager.ObjectClicked.connect(_on_ObjectClicked)

func _on_ObjectClicked(event_position, object_info):
	var player_clicked_cauldron = object_info.is_in_group("cauldron")
	var player_clicked_potion = object_info.is_in_group("potion")
	var object = object_info.get_parent().get_parent()

	if player_clicked_cauldron:
		clicking_cauldron(object)
	elif player_clicked_potion:
		clicking_potion(object)

func clicking_cauldron(cauldron: Node3D):
	if selected_potion:
		var containers_are_available = not (selected_potion.being_poured_into or selected_potion.pouring or cauldron.being_poured_into)
		if containers_are_available:
			selected_potion.pour_potion(cauldron, EXTRA_POTION_HEIGHT, POUR_TIME_SECONDS)
			remove_selection_outline(selected_potion)
			selected_potion = null
			
		
func clicking_potion(potion):
	if selected_potion:
		
		var potion_into_another_potion = selected_potion and selected_potion != potion
		var potions_are_available = not (selected_potion.being_poured_into or selected_potion.pouring or potion.pouring or potion.being_poured_into)
		if potion_into_another_potion and potions_are_available:
			selected_potion.pour_potion(potion, EXTRA_POTION_HEIGHT, POUR_TIME_SECONDS)
		
		remove_selection_outline(selected_potion)
		selected_potion = null			
	# There isn't a potion selected
	else:
		selected_potion = potion
		
		if selection_mesh == null:
			add_selection_outline(selected_potion)
		else:
			remove_selection_outline(selected_potion)			
		
		
func add_selection_outline(potion: Node3D) -> void:
	var potion_mesh = potion.get_child(0).get_child(0).mesh
	var selection_outline = potion_mesh.duplicate()
	
	selection_outline.surface_set_material(0, load(OUTLINE_MATERIAL_PATH))
	
	selection_mesh = MeshInstance3D.new()
	selection_mesh.mesh = selection_outline
	selection_mesh.scale /= 17.8  # Slightly larger to create the outline effect
	potion.add_child(selection_mesh)

func remove_selection_outline(potion: Node3D) -> void:
	potion.remove_child(selection_mesh)
	selection_mesh.queue_free()
	selection_mesh = null
	
