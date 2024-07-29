extends RigidBody3D

var timer = 0.0
var swing_amplitude_x = 0.3
var swing_amplitude_z = 0.3
var randomness_factor = 0.2
var noise: FastNoiseLite

# Called when the node enters the scene tree for the first time.
func _ready():
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = 1
	noise.frequency = 0.5

func _physics_process(delta):
	timer += delta
	var noise_x = noise.get_noise_2d(timer, 0) * swing_amplitude_x
	var noise_z = noise.get_noise_2d(0, timer) * swing_amplitude_z
	var torque_x = noise_x + (randf_range(-0.23, 1.0) * randomness_factor)
	var torque_z = noise_z + (randf_range(-0.23, 1.0) * randomness_factor)
	var torque = Vector3(torque_x, 0, torque_z)
	apply_torque(torque)
