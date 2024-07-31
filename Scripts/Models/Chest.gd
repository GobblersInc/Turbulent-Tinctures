extends Node3D

@export var open_chance: float
@onready var lantern = $"../Lantern"

var original_lid_position: Vector3
var original_lid_rotation: Vector3
var original_left_iris_position: Vector3
var original_left_eyeball_position: Vector3
var original_right_iris_position: Vector3
var original_right_eyeball_position: Vector3
var target_position: Vector3
var lid: MeshInstance3D
var right_iris: MeshInstance3D
var right_eyeball: MeshInstance3D
var left_iris: MeshInstance3D
var left_eyeball: MeshInstance3D
var right_eyeball_material: StandardMaterial3D
var left_eyeball_material: StandardMaterial3D

# Called when the node enters the scene tree for the first time.
func _ready():
	lid = self.find_child("chest lid")
	left_eyeball = self.find_child("green part")
	left_iris = self.find_child("black part")
	right_eyeball = self.find_child("greeb part_001")
	right_iris = self.find_child("black part_001")
	right_eyeball_material = right_eyeball.mesh.surface_get_material(0)
	left_eyeball_material = left_eyeball.mesh.surface_get_material(0)
	original_lid_position = lid.position
	original_lid_rotation = lid.rotation
	original_left_eyeball_position = left_eyeball.position
	original_left_iris_position = left_iris.position
	original_right_iris_position = right_iris.position
	original_right_eyeball_position = right_eyeball.position
	
	target_position = original_lid_position
	target_position.y += 1
	lantern.LightOff.connect(_handle_light_off)

func _handle_light_off():
	if should_open_chest():
		var tween = get_tree().create_tween().set_parallel(true)
		
		# Return to original position and rotation
		tween.tween_property(self.find_child("chest lid"), 
							"position", 
							target_position, 
							1)
		tween.tween_property(self.find_child("chest lid"), 
							"rotation_degrees", 
							Vector3(0, 1440, 0), 
							1)
		tween.tween_property(left_iris, 
							"position", 
							Vector3(original_left_iris_position.x, original_left_iris_position.y + .8, original_left_iris_position.z), 
							2)
		tween.tween_property(right_iris, 
							"position", 
							Vector3(original_right_iris_position.x, original_right_iris_position.y + .8, original_right_iris_position.z), 
							2)
		tween.tween_property(left_eyeball, 
							"position", 
							Vector3(original_left_eyeball_position.x, original_left_eyeball_position.y + .8, original_left_eyeball_position.z), 
							2)
		tween.tween_property(right_eyeball, 
							"position", 
							Vector3(original_right_eyeball_position.x, original_right_eyeball_position.y + .8, original_right_eyeball_position.z), 
							2)
		tween.tween_property(right_eyeball_material, 
							"emission_energy_multiplier", 
							5, 
							3)
		tween.tween_property(left_eyeball_material, 
							"emission_energy_multiplier", 
							5, 
							3)
		await tween.finished
		close_chest()

func close_chest():
	var tween = get_tree().create_tween().set_parallel(true)
		
		# Return to original position and rotation
	tween.tween_property(self.find_child("chest lid"), 
						"position", 
						original_lid_position, 
						1)
	tween.tween_property(self.find_child("chest lid"), 
						"rotation_degrees", 
						original_lid_rotation, 
						1)
	tween.tween_property(left_iris, 
						"position", 
						original_left_iris_position, 
						2)
	tween.tween_property(right_iris, 
						"position", 
						original_right_iris_position, 
						2)
	tween.tween_property(left_eyeball, 
						"position", 
						original_left_eyeball_position, 
						2)
	tween.tween_property(right_eyeball, 
						"position", 
						original_right_eyeball_position, 
						2)
	tween.tween_property(right_eyeball_material, 
						"emission_energy_multiplier", 
						0, 
						10.5)
	tween.tween_property(left_eyeball_material, 
						"emission_energy_multiplier", 
						0, 
						.5)

func should_open_chest() -> bool:
	return randf() < open_chance

