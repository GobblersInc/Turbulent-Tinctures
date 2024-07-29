extends AnimationPlayer

func fade_to_black(seconds):
	self.play("FadeToBlack")
	self.speed_scale = seconds

func fade_from_black(seconds):
	self.play("FadeToBlack")
	self.speed_scale = -seconds
