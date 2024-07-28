extends Node3D 

@onready var camera = $"../../Camera3D"

signal ObjectClicked(event_position, clicked_object)

func get_intersect_ray(mouse_position, camera, space_state):
	var params = PhysicsRayQueryParameters3D.new()
	params.from = camera.project_ray_origin(mouse_position)
	params.to = params.from + camera.project_ray_normal(mouse_position) * 1000
	params.collide_with_areas = true
	params.collide_with_bodies = true
	
	return space_state.intersect_ray(params)

func _input(event: InputEvent) -> void:
	var space_state = get_world_3d().direct_space_state
	
	var intersect_ray
	
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		intersect_ray = get_intersect_ray(event.position, camera, space_state)

	var cursor_shape = Input.CURSOR_ARROW

	if intersect_ray:
		var clicked_object = intersect_ray.collider
		if clicked_object.is_in_group("clickable"):
			cursor_shape = Input.CURSOR_POINTING_HAND
			if Input.is_action_just_pressed("LeftClick"):
				ObjectClicked.emit(event.position, clicked_object)
	Input.set_default_cursor_shape(cursor_shape)
	
	get_viewport().set_input_as_handled()
