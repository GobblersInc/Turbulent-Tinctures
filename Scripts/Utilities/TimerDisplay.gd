extends AnimationPlayer

@onready var time_left_label = $"../TimeLeft"

func fade_text_in() -> void:
	self.play("FadeTextIn")
	self.speed_scale = 0.75

func fade_text_out() -> void:
	self.play("FadeTextIn")
	self.speed_scale = -0.75
