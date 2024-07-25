extends Node3D

@onready var rng = RandomNumberGenerator.new()
@onready var timer = $Timer

@export var checkFrequency: int 
@export var percentChance: float

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.wait_time = checkFrequency
	timer.connect("timeout", _on_timer_timeout)
	
	timer.start()

func _on_timer_timeout():
	if rng.randf() < percentChance:
		SoundManager.play_random_ship_sound()
