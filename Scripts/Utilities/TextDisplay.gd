extends AnimationPlayer

@onready var center_text = $"../Label"

func fade_text_in(text: String) -> void:
	center_text.text = text
	self.play("FadeTextIn")
	self.speed_scale = 0.75

func fade_text_out() -> void:
	self.play("FadeTextIn")
	self.speed_scale = -0.75
