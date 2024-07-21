extends Node3D 

@onready var camera = $"../Camera3D"

signal ObjectClicked(event_position, clicked_object)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("LeftClick"):
		var space_state = get_world_3d().direct_space_state
		var ray_origin = camera.project_ray_origin(event.position)
		var ray_end = ray_origin + camera.project_ray_normal(event.position) * 1000
		var query = PhysicsRayQueryParameters3D.new()
		query.from = ray_origin
		query.to = ray_end
		query.collide_with_areas = true
		query.collide_with_bodies = true
		
		var result = space_state.intersect_ray(query)
		if result:
			var clicked_object = result.collider
			ObjectClicked.emit(event.position, clicked_object)
		get_viewport().set_input_as_handled()
