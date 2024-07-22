extends Node3D

@onready var input_manager = $"../Managers/InputManager"
@onready var camera = $"../Camera3D"
@onready var is_in_front: bool = false
@onready var light: OmniLight3D = null
@export var animation_time = .5

var original_position: Vector3
var original_rotation: Vector3
var camera_offset: Vector3

func _ready():
	# Initialize the original position and rotation
	var lantern = get_node("../Lantern")
	light = lantern.find_child("LanternLight", true, false)

	original_position = position
	original_rotation = rotation_degrees
	
	# Calculate the camera offset
	var camera_position = camera.global_transform.origin
	camera_offset = Vector3(camera_position.x,
							camera_position.y - 1.4, 
							camera_position.z - 3.25)
	input_manager.ObjectClicked.connect(_on_ObjectClicked)

func _on_ObjectClicked(_event_position, clicked_object):
	if clicked_object.is_in_group("paper"):
		_handle_paper_clicked()

func _handle_paper_clicked() -> void:
	if is_in_front:
		var tween = get_tree().create_tween().set_parallel(true)
		
		# Return to original position and rotation
		tween.tween_property(self, 
							"position", 
							original_position, 
							animation_time)
		tween.tween_property(self, 
							"rotation_degrees", 
							original_rotation, 
							animation_time)
	else:
		# Move and rotate the paper to be in front of the camera
		if light.light_energy > 0:
			var tween = get_tree().create_tween().set_parallel(true)
			tween.tween_property(self, "position", camera_offset, animation_time)
			tween.tween_property(self, "rotation_degrees", Vector3(0, -90, -75), animation_time)
	
	# Toggle the state
	is_in_front = !is_in_front
