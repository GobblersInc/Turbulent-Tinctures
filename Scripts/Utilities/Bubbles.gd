extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	InteractionManager.AddIngredient.connect(_on_AddIngredient)
	GameManager.MixAttempt.connect(_stop_bubbles)
	self.visible = false
	
func _stop_bubbles():
	SoundManager.stop_audio_player("bubbling")
	self.visible = false

func _on_AddIngredient(_throw_away):
	SoundManager.play_random_bubbling_sound()
	self.visible = true
