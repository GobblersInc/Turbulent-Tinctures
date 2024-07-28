extends AnimationPlayer

func fade_to_black():
	self.play("FadeToBlack")
	self.speed_scale = 1

func fade_from_black():
	self.play("FadeToBlack")
	print("fade_from_black")
	self.speed_scale = -1
