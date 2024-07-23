extends Node3D

@onready var pouring = false
@onready var cauldron = $"../Cauldron"
@onready var animation_time: float = .25

var original_position: Vector3
var original_rotation: Vector3
var cauldron_position: Vector3

@export var pour_time: float

func _ready():
	original_position = position
	original_rotation = rotation_degrees
	cauldron_position = Vector3(cauldron.position.x, cauldron.position.y + 1, cauldron.position.z)

func pour_potion(receiver: Node3D):
	"""
	Move to receiver turned upside-down, wait a number of seconds, then return to original position.
	"""
	pouring = true
	receiver.being_poured_into = true
	move_to_cauldron()
	
	await delay(pour_time)
	
	move_to_original_position()
	pouring = false
	receiver.being_poured_into = false

func delay(seconds: float):
	await get_tree().create_timer(seconds).timeout
	
func move_to_cauldron():
	var tween = get_tree().create_tween().set_parallel(true)
	
	# Return to original position and rotation
	tween.tween_property(self, 
						"position", 
						cauldron_position,
						animation_time)
	tween.tween_property(self, 
						"rotation_degrees", 
						Vector3(180, 0 , 0), 
						animation_time)

func move_to_original_position():
	var tween = get_tree().create_tween().set_parallel(true)
	
	# Return to original position and rotation
	tween.tween_property(self, 
						"position", 
						original_position,
						animation_time)
	tween.tween_property(self, 
						"rotation_degrees", 
						original_position, 
						animation_time)
