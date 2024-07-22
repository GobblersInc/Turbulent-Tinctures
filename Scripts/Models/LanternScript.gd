extends Node3D

@onready var input_manager = $"../Managers/InputManager"

func _ready():
	input_manager.ObjectClicked.connect(_on_ObjectClicked)

func _on_ObjectClicked(event_position, clicked_object):
	if clicked_object.is_in_group("lantern"):
		_handle_lantern_clicked()

func _handle_lantern_clicked() -> void:
	print("Lantern clicked!")
