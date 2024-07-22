extends Node3D

@onready var pouring = false
@onready var being_poured_into = false

func pour_potion(receiver: Node3D, extra_potion_height: float, pour_time: float):
	"""
	Move to receiver turned upside-down, wait a number of seconds, then return to original position.
	"""
	pouring = true
	receiver.being_poured_into = true
	var pourer_position = global_transform.origin
	var receiver_position = receiver.global_transform.origin
	move_to_coordinates(receiver_position.x, receiver_position.y, receiver_position.z, extra_potion_height)

	flip(true)
	await delay(pour_time)
	flip(false)

	move_to_coordinates(pourer_position.x, pourer_position.y, pourer_position.z, 0)
	pouring = false
	receiver.being_poured_into = false

func flip(turn_upside_down: bool):
	rotation_degrees.x = 180 if turn_upside_down else 0

func delay(seconds: float):
	await get_tree().create_timer(seconds).timeout

func move_to_coordinates(x, y, z, extra_height):
	global_transform.origin = Vector3(x, y+extra_height, z)
