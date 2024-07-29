extends Node3D

@onready var being_poured_into = false
@onready var lantern = $"../Lantern"


# Called when the node enters the scene tree for the first time.
func _ready():
	lantern.LightOff.connect(_lantern_light_off)
	lantern.LightOn.connect(_lantern_light_on)
	SoundManager.play_boiling_water_sound()
	
func _lantern_light_off():
	_set_cauldron_emission(true)
	
func _lantern_light_on():
	_set_cauldron_emission(false)

func _set_cauldron_emission(enabled: bool):
	var cauldron_mesh: ArrayMesh = self.get_child(0).get_child(0).mesh
	for i in range(cauldron_mesh.get_surface_count()):
		var material: StandardMaterial3D = cauldron_mesh.surface_get_material(i)
		if material:
			if enabled:
				material.emission_enabled = true
				material.emission = Color(0.041, 0, 0.113)
				material.emission_energy = .5
			else:
				material.emission_enabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
