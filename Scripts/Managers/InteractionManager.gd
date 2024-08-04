extends Node3D 

@onready var cauldron = get_node("/root/PirateShip/Cauldron")
@onready var paper = get_node("/root/PirateShip/Paper")
@onready var lantern = get_node("/root/PirateShip/Lantern")

signal AddIngredient(potion)
signal MixIngredients()

var selection_mesh: MeshInstance3D = null
const OUTLINE_MATERIAL_PATH = "res://Resources/Materials/Outline.tres"

var selected_potion = null
var hovered_item = null

func _ready():
	InputManager.ObjectClicked.connect(_on_ObjectClicked)
	InputManager.HoverStatus.connect(_on_ObjectHovered)
	cauldron.DonePouring.connect(_on_DonePouring)
	lantern.LightOff.connect(_on_LightOff)

func _on_DonePouring():
	if selected_potion:
		add_cauldron_outline()
		
func _on_LightOff():
	remove_paper_outline()


func _on_ObjectHovered(hovered_object_info, hovering):
	if not hovering:
		if not hovered_item:
			return

		var groups = hovered_item.get_groups()
		remove_outline(hovered_item, groups)
		hovered_item = null
		return
	
	var hovered_object = hovered_object_info.get_parent().get_parent()
	var groups = hovered_object.get_groups()
	
	if hovered_item:
		var old_groups = hovered_item.get_groups()
		remove_outline(hovered_item, old_groups)
	hovered_item = hovered_object
	
	add_outline(hovered_item, groups)

func add_outline(hovered_object, groups):
	if "potion" in groups:
		add_potion_outline(hovered_object)
	elif "cauldron" in groups:
		add_cauldron_outline()
	elif "paper" in groups:
		if lantern.is_light_on:
			add_paper_outline()

func remove_outline(hovered_object, groups):
	if "potion" in groups:
		remove_potion_outline(hovered_object)
	elif "cauldron" in groups:
		if not selected_potion:
			remove_cauldron_outline()
	elif "paper" in groups:
		remove_paper_outline()

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
			selected_potion.selected = false
			selected_potion.can_be_selected = false
			AddIngredient.emit(selected_potion.potion_data)
			selected_potion = null
			add_cauldron_outline()
	else:
		MixIngredients.emit()

func clicking_potion(potion: Node3D):
	if not potion.can_be_selected:
		return

	var player_clicked_same_potion = potion == selected_potion
	
	if player_clicked_same_potion:
		# Deselect the potion.
		potion.selected = false
		selected_potion = null
		remove_cauldron_outline()
	# The player selected a different potion, or is clicking a potion for the first time..
	else:
		# The player has a potion already selected
		if selected_potion:
			# Remove its outline.
			selected_potion.selected = false
			remove_potion_outline(selected_potion)
			remove_cauldron_outline()
		
		# Update the selected potion
		selected_potion = potion
		potion.selected = true
		
		SoundManager.play_random_potion_interact_sound()
		add_cauldron_outline()

func add_potion_outline(potion: Node3D) -> void:
	var mesh_instance: MeshInstance3D = potion.find_child("PotionOutline")
	mesh_instance.visible = true
	
func remove_potion_outline(potion: Node3D) -> void:
	if potion.selected:
		return

	var mesh_instance: MeshInstance3D = potion.find_child("PotionOutline")
	mesh_instance.visible = false
		
func add_cauldron_outline() -> void:
	if cauldron.being_poured_into:
		return
	var mesh_instance = cauldron.get_child(0).get_child(8)
	
	mesh_instance.visible = true
	
func remove_cauldron_outline() -> void:
	var mesh_instance = cauldron.get_child(0).get_child(8)
	
	mesh_instance.visible = false
	
func add_paper_outline() -> void:
	var mesh_instance = paper.get_child(0).get_child(1)
	
	mesh_instance.visible = true
	
func remove_paper_outline() -> void:
	var mesh_instance = paper.get_child(0).get_child(1)
	
	mesh_instance.visible = false
	
