extends Node3D

@onready var pouring = false
@onready var cauldron = get_node("/root/PirateShip/Cauldron")
@onready var animation_time: float = 0.25

var original_position: Vector3
var original_rotation: Vector3
var cauldron_position: Vector3

var can_be_selected = true
var potion_data = null

var original_fluid_position: Vector3
var original_fluid_scale: Vector3

const JUG_POTION_Y_OFFSET: float = 0
const FLASK_POTION_Y_OFFSET: float = .5
const VIAL_POTION_Y_OFFSET: float = 0

const JUG_POTION_POURING_POSITION: Vector3 = Vector3(0, 2, 0)
const FLASK_POTION_POURING_POSITION: Vector3 = Vector3(0, 6, 0)
const VIAL_POTION_POURING_POSITION: Vector3 = Vector3(0, 5, 0)

const FINAL_SCALE: Vector3 = Vector3(0, 0, 0)

var pour_time: float = 1
var has_hover_outline = false
var selected = false
var tween: Tween

func _ready():
	original_position = global_transform.origin
	original_rotation = global_rotation_degrees
	cauldron_position = Vector3(cauldron.position.x + .25, cauldron.position.y + 2, cauldron.position.z + 2)

func pour_potion(cauldron: Node3D):
	pouring = true
	cauldron.being_poured_into = true
	move_to_cauldron()

	pour_liquid()
	await delay(pour_time)

	throw_potion()

	await delay(.17)

	move_to_original_position()
	reset_liquid()
	pouring = false
	cauldron.being_poured_into = false
	cauldron.DonePouring.emit()

func delay(seconds: float):
	await get_tree().create_timer(seconds).timeout

func move_to_cauldron():
	SoundManager.play_random_mixing_sound()
	tween = create_tween().set_parallel(true)
	set_cork_visibility(false)
	tween.tween_property(self, 
						"position", 
						cauldron_position,
						animation_time)
	tween.tween_property(self, 
						"rotation_degrees", 
						Vector3(0, 0, 130), 
						animation_time)

func pour_liquid():
	tween = create_tween().set_parallel(true)
	var fluid: MeshInstance3D = self.find_child("fluid")
	
	if fluid:
		# Store original position and scale
		original_fluid_position = fluid.position
		original_fluid_scale = fluid.scale
		
		var final_position: Vector3
		
		if self.is_in_group("vial_potion"):
			final_position = VIAL_POTION_POURING_POSITION
		elif self.is_in_group("jug_potion"):
			final_position = JUG_POTION_POURING_POSITION
		else:
			final_position = FLASK_POTION_POURING_POSITION
		
		tween.tween_property(fluid, 
						"scale", 
						FINAL_SCALE,
						.75).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(fluid, 
						"position", 
						final_position,
						.75).set_ease(Tween.EASE_IN_OUT)

func reset_liquid():
	var fluid: MeshInstance3D = self.find_child("fluid")
	if fluid:
		fluid.scale = original_fluid_scale
		fluid.position = original_fluid_position

func set_cork_visibility(isVisible: bool):
	var cork: MeshInstance3D = self.find_child("cap")
	if cork:
		cork.visible = isVisible

func throw_potion():
	tween = create_tween().set_parallel(true)
	var x_positions = [-2, 2]
	tween.tween_property(self, 
						"position", 
						Vector3(x_positions[randi() % x_positions.size()], randi_range(2, 4), randi_range(-3, 3)),
						.15)
	tween.tween_property(self, 
						"rotation_degrees", 
						Vector3(720, 0 , 0), 
						.15)
						
	SoundManager.player_random_glass_break_sound()

func move_to_original_position():
	set_cork_visibility(true)
	self.global_transform.origin = original_position
	self.global_rotation_degrees = original_rotation
	
func remove_potion_outline() -> void:
	if selected:
		return

	var mesh_instance: MeshInstance3D = find_child("PotionOutline")
	mesh_instance.visible = false

func is_disabled():
	return not can_be_selected
