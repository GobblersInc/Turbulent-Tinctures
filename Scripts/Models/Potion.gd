extends Node3D

@onready var pouring = false
@onready var cauldron = $"../../../Cauldron"
@onready var animation_time: float = 0.25

var original_position: Vector3
var original_rotation: Vector3
var cauldron_position: Vector3

# This is only false if it's a resulting potion being spawned or it's pouring into a cauldron
var can_be_selected = true 
var potion_data = null

const JUG_POTION_Y_OFFSET: float = 0
const FLASK_POTION_Y_OFFSET: float = .5
const VIAL_POTION_Y_OFFSET: float = 0

const JUG_POTION_POURING_POSITION: Vector3 = Vector3(0, 2, 0)
const FLASK_POTION_POURING_POSITION: Vector3 = Vector3(0, 6, 0)
const VIAL_POTION_POURING_POSITION: Vector3 = Vector3(0, 5, 0)
const JUG_POTION_POURING_SCALE: Vector3 = Vector3(0, 0, 0)
const FLASK_POTION_POURING_SCALE: Vector3 = Vector3(0, 0, 0)
const VIAL_POTION_POURING_SCALE: Vector3 = Vector3(0, 0 , 0)

var pour_time: float = 1

func _ready():
	original_position = global_transform.origin
	original_rotation = global_rotation_degrees
	cauldron_position = Vector3(cauldron.position.x + .25, cauldron.position.y + 2, cauldron.position.z + 2)

func pour_potion(cauldron: Node3D):
	"""
	Move to cauldron turned upside-down, wait a number of seconds, then return to original position.
	"""
	pouring = true
	cauldron.being_poured_into = true
	move_to_cauldron()

	pour_liquid()
	await delay(pour_time)

	throw_potion()

	await delay(.17)

	move_to_original_position()
	pouring = false
	cauldron.being_poured_into = false

	queue_free()

func delay(seconds: float):
	await get_tree().create_timer(seconds).timeout
	
func move_to_cauldron():
	SoundManager.play_random_mixing_sound()
	var tween = get_tree().create_tween().set_parallel(true)
	set_cork_visibility(false)
	# Move to cauldron position and rotate
	tween.tween_property(self, 
						"position", 
						cauldron_position,
						animation_time)
	tween.tween_property(self, 
						"rotation_degrees", 
						Vector3(0, 0, 130), 
						animation_time)
						
func pour_liquid():
	var tween = get_tree().create_tween().set_parallel(true)
	var fluid: MeshInstance3D = self.find_child("fluid")
	var final_scale: Vector3
	var final_position: Vector3
	if self.is_in_group("vial_potion"):
		final_position = VIAL_POTION_POURING_POSITION
		final_scale = VIAL_POTION_POURING_SCALE
	elif self.is_in_group("jug_potion"):
		final_position = JUG_POTION_POURING_POSITION
		final_scale = JUG_POTION_POURING_SCALE
	else:
		final_position = FLASK_POTION_POURING_POSITION
		final_scale = FLASK_POTION_POURING_SCALE
	
	
	if fluid:
		tween.tween_property(fluid, 
						"scale", 
						final_scale,
						.75).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(fluid, 
						"position", 
						final_position,
						.75).set_ease(Tween.EASE_IN_OUT)
						
func set_cork_visibility(isVisible: bool):
	var cork: MeshInstance3D = self.find_child("Cork")
	if cork:
		cork.visible = isVisible
						
func throw_potion():
	var tween = get_tree().create_tween().set_parallel(true)
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
