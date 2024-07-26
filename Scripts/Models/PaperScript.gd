extends Node3D

@onready var camera = $"../Camera3D"
@onready var is_in_front: bool = false
@onready var light: OmniLight3D = null

@export var animation_time = .5

@onready var input_manager = $"../Managers/InputManager"
@onready var lantern = $"../Lantern"

var original_position: Vector3
var original_rotation: Vector3
var camera_offset: Vector3

func _ready():
	# Initialize the original position and rotation
	light = lantern.find_child("LanternLight", true, false)

	original_position = position
	original_rotation = rotation_degrees
	
	# Calculate the camera offset
	var camera_position = camera.global_transform.origin
	camera_offset = Vector3(camera_position.x,
							camera_position.y - 1.625, 
							camera_position.z - 3.1)
	input_manager.ObjectClicked.connect(_on_ObjectClicked)
	lantern.LightOff.connect(_handle_light_off)

func _on_ObjectClicked(_event_position, clicked_object):
	if clicked_object.is_in_group("paper"):
		_handle_paper_clicked()

func _handle_paper_clicked() -> void:
	if self.position == original_position or self.position == camera_offset:
		if is_in_front:
			put_down()
		else:
			# Move and rotate the paper to be in front of the camera
			if light.light_energy > 0:
				put_in_front()
			
func put_down():
	is_in_front = !is_in_front
	SoundManager.play_random_paper_sound()
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
	await tween.finished
	set_paper_emmission(false)
	
func put_in_front():
	is_in_front = !is_in_front
	set_paper_emmission(true)
	SoundManager.play_random_paper_sound()
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(self, "position", camera_offset, animation_time)
	tween.tween_property(self, "rotation_degrees", Vector3(0, -90, -70), animation_time)
	await tween.finished

func _handle_light_off():
	if is_in_front:
		put_down()

func set_paper_emmission(enabled: bool):
	var paper_mesh: ArrayMesh = self.get_child(0).get_child(0).mesh
	for i in range(paper_mesh.get_surface_count()):
		var material: StandardMaterial3D = paper_mesh.surface_get_material(i)
		if material:
			if enabled:
				material.emission_enabled = true
				material.emission = Color(0.821, 0.571, 0.084)
				material.emission_energy = 1
			else:
				material.emission_enabled = false
	
