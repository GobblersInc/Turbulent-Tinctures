extends Node3D 

@onready var camera = $"../../Camera3D"

signal ObjectClicked(event_position, clicked_object)

func has_been_clicked(mouse_position, space_state):
	var params = PhysicsRayQueryParameters3D.new()
	params.from = camera.project_ray_origin(mouse_position)
	params.to = params.from + camera.project_ray_normal(mouse_position) * 1000
	params.collide_with_areas = true
	params.collide_with_bodies = true
	
	return space_state.intersect_ray(params)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("LeftClick"):
		var space_state = get_world_3d().direct_space_state
		
		var result = has_been_clicked(event.position, space_state)
		if result:
			var clicked_object = result.collider
			ObjectClicked.emit(event.position, clicked_object)
		get_viewport().set_input_as_handled()
