extends Node3D

@onready var pouring = false
@onready var cauldron = $"../../../Cauldron"
@onready var animation_time: float = 0.25

var original_position: Vector3
var original_rotation: Vector3
var cauldron_position: Vector3

var potion_data = null

var pour_time: float = 1

func _ready():
	original_position = global_transform.origin
	original_rotation = global_rotation_degrees
	cauldron_position = Vector3(cauldron.position.x + .25, cauldron.position.y + 2, cauldron.position.z + 2)

func pour_potion(receiver: Node3D):
	"""
	Move to receiver turned upside-down, wait a number of seconds, then return to original position.
	"""
	pouring = true
	receiver.being_poured_into = true
	move_to_cauldron()
	
	await delay(pour_time)
	
	throw_potion()
	
	await delay(.15)
	
	move_to_original_position()
	pouring = false
	receiver.being_poured_into = false

func delay(seconds: float):
	await get_tree().create_timer(seconds).timeout
	
func move_to_cauldron():
	SoundManager.play_random_mixing_sound()
	var tween = get_tree().create_tween().set_parallel(true)
	
	# Move to cauldron position and rotate
	tween.tween_property(self, 
						"position", 
						cauldron_position,
						animation_time)
	tween.tween_property(self, 
						"rotation_degrees", 
						Vector3(0, 0, 130), 
						animation_time)
						
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
	self.global_transform.origin = original_position
	self.global_rotation_degrees = original_rotation
