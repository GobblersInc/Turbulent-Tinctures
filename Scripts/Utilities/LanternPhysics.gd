extends RigidBody3D

# Parameters to control the swaying
var sway_angle_x = 10.0  # Maximum sway angle in degrees for X axis
var sway_angle_z = 15.0  # Maximum sway angle in degrees for Z axis
var sway_speed_x = 1.0  # Speed of the swaying motion on the X axis
var sway_speed_z = 1.3  # Speed of the swaying motion on the Z axis
var randomness_factor = 0.1  # Factor to introduce randomness in the motion

var time_elapsed = 0.0  # Internal timer

func _process(delta):
	time_elapsed += delta

	# Calculate the sway angles using sine and cosine waves with some randomness
	var angle_x = sin(time_elapsed * sway_speed_x + randf() * randomness_factor) * sway_angle_x
	var angle_z = cos(time_elapsed * sway_speed_z + randf() * randomness_factor) * sway_angle_z

	# Apply the calculated rotation to the lantern pivot
	rotation_degrees.x = angle_x
	rotation_degrees.z = angle_z
