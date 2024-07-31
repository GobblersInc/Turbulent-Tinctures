extends SpotLight3D

@onready var lightning = $"."
@onready var timer = $Timer

@export var lightning_chance: float
@export var timer_wait_time: float

var tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.connect("timeout", _on_timer_timeout)

func _on_timer_timeout():
	if should_lightning_strike():
		do_lightning_strike()

func should_lightning_strike() -> bool:
	return randf() < lightning_chance

func do_lightning_strike():
	if tween:
		tween.kill()
	tween = create_tween()
	
	# Return to original position and rotation
	tween.tween_property(self, "light_energy", 45, 0.2)
	tween.tween_property(self, "light_energy", 20, 0.2)
	tween.tween_property(self, "light_energy", 40, 0.2)
	tween.tween_property(self, "light_energy", 0, 0.1)
	
