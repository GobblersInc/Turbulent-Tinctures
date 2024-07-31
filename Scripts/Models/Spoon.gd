extends Node3D

@onready var movement_manager = $"../Managers/MovementManager"
var original_position: Vector3
var original_rotation: Vector3
var stirring_position: Vector3
@onready var radius_x = .1  # Radius for x axis
@onready var radius_z = .1  # Radius for z axis (adjust for elliptical path)
@onready var speed = 7.5  # Speed of the stirring motion
var max_angle = 6 * PI  # 720 degrees in radians (2 full circles)
var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	movement_manager.MixIngredients.connect(_on_MixIngredient)
	original_position = self.position
	original_rotation = self.rotation
	stirring_position =  Vector3(self.position.x + .2, self.position.y, self.position.z + .2)

func _on_MixIngredient():
	if self.position == original_position:
		await move_spoon()
	elif self.position != stirring_position:
		tween.stop()
	start_stirring()

func move_spoon():
	tween = create_tween()
	tween.tween_property(self, "position", stirring_position, 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

func start_stirring():
	# Create a coroutine to handle the stirring motion
	var angle = 0.0
	while angle < max_angle:
		tween = create_tween()
		# Calculate new position
		var x = stirring_position.x + radius_x * cos(angle)
		var z = stirring_position.z + radius_z * sin(angle)
		var new_position = Vector3(x, original_position.y, z)

		# Animate position and rotation change
		tween.tween_property(self, "position", new_position, 0.1).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		
		await tween.finished  # Wait for the tween to complete

		# Update the angle for the next step
		angle += speed * 0.1
		
	self.position = original_position
