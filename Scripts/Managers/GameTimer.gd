extends Timer
@onready var time_left_label = get_node("/root/PirateShip/CanvasLayer/TimeLeft")

signal TimeOut()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_left_label.text = str(int(self.time_left))
	if self.time_left <= 0:
		TimeOut.emit()
