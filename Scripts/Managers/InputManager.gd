extends Node3D 

@onready var camera = $"../../Camera3D"
@onready var game_manager = $"../GameManager"
var game_lost = false
var game_paused = false

signal ObjectClicked(event_position, clicked_object)
signal ClickAfterGameLoss()

func _ready():
	game_manager.GameLoss.connect(_on_GameLoss)
	game_manager.GamePause.connect(_on_GamePause)
	
func reset_cursor():
	var cursor_shape = Input.CURSOR_ARROW
	Input.set_default_cursor_shape(cursor_shape)
	
func _on_GamePause(is_paused):
	game_paused = is_paused
	
	if game_paused:
		reset_cursor()

func _on_GameLoss():
	reset_cursor()
	game_lost = true

func get_intersect_ray(mouse_position, camera, space_state):
	var params = PhysicsRayQueryParameters3D.new()
	params.from = camera.project_ray_origin(mouse_position)
	params.to = params.from + camera.project_ray_normal(mouse_position) * 1000
	params.collide_with_areas = true
	params.collide_with_bodies = true
	
	return space_state.intersect_ray(params)

func _input(event: InputEvent) -> void:
	get_viewport().set_input_as_handled()
	var cursor_shape = Input.CURSOR_ARROW	

	var clicked = Input.is_action_just_pressed("LeftClick")
	if game_lost:
		if clicked:
			ClickAfterGameLoss.emit()
	elif not game_paused:
		var space_state = get_world_3d().direct_space_state
		
		var intersect_ray = get_intersect_ray(event.position, camera, space_state)
		
		if intersect_ray:
			var clicked_object = intersect_ray.collider
			if clicked_object.is_in_group("clickable"):
				cursor_shape = Input.CURSOR_POINTING_HAND
				if clicked and event is InputEventMouseButton:
					ObjectClicked.emit(event.position, clicked_object)

	Input.set_default_cursor_shape(cursor_shape)
