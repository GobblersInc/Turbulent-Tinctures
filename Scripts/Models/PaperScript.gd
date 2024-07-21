extends Node3D

@onready var input_manager = $"../InputManager"

func _ready():
	input_manager.ObjectClicked.connect(_on_ObjectClicked)

func _on_ObjectClicked(event_position, clicked_object):
	if clicked_object.is_in_group("paper"):
		_handle_paper_clicked()

func _handle_paper_clicked() -> void:
	print("Paper clicked!")
