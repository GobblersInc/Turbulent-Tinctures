extends Node

const FluidType = preload("res://Scripts/Utilities/PotionData.gd").FluidType
const BottleType = preload("res://Scripts/Utilities/PotionData.gd").BottleType

# Helper function to convert a string to the appropriate enum value
func _get_fluid_type(fluid_str: String):
	for fluid in FluidType.values():
		if fluid_str == FluidType.keys()[fluid]:
			return fluid
	return null

func _get_bottle_type(bottle_str: String):
	for bottle in BottleType.values():
		if bottle_str == BottleType.keys()[bottle]:
			return bottle
	return null

# Function to process each node in the dictionary and generate GDScript statements
func process_node(data: Dictionary, parent_var: String, potion_count: int, all_potions: Dictionary) -> Dictionary:
	var statements = ""
	var local_potion_count = potion_count  # Use a local variable to avoid modifying the potion_count directly
	
	for key in data.keys():
		var parts = key.split(":")
		var fluid_str = parts[0]
		var bottle_str = parts[1]
		
		var fluid = _get_fluid_type(fluid_str)
		var bottle = _get_bottle_type(bottle_str)
		
		var potion_var = "potion_%d" % local_potion_count
		local_potion_count += 1
		
		statements += "var %s = all_potions[BottleType.%s][FluidType.%s]\n" % [potion_var, bottle_str, fluid_str]
		if parent_var != "":
			statements += "%s.add_ingredient(%s)\n" % [parent_var, potion_var]
		
		if typeof(data[key]) == TYPE_DICTIONARY:
			var result = process_node(data[key], potion_var, local_potion_count, all_potions)
			statements += result["statements"]
			local_potion_count = result["potion_count"]
	
	return {"statements": statements, "potion_count": local_potion_count}

# Function to convert the dictionary into PotionData initialization statements
func convert_to_potion_data_statements(data: Dictionary, all_potions: Dictionary) -> String:
	var statements = ""
	var potion_count = 0
	
	for key in data.keys():
		var parts = key.split(":")
		var fluid_str = parts[0]
		var bottle_str = parts[1]
		
		var fluid = _get_fluid_type(fluid_str)
		var bottle = _get_bottle_type(bottle_str)
		
		var root_var = "potion_%d" % potion_count
		potion_count += 1
		
		statements += "var %s = all_potions[BottleType.%s][FluidType.%s]\n" % [root_var, bottle_str, fluid_str]
		
		if typeof(data[key]) == TYPE_DICTIONARY:
			var result = process_node(data[key], root_var, potion_count, all_potions)
			statements += result["statements"]
			potion_count = result["potion_count"]
	
	return statements
	
func _ready():
	# Create a sample all_potions dictionary for demonstration
	var all_potions = {}
	for bottle in BottleType.values():
		all_potions[bottle] = {}
		for fluid in FluidType.values():
			all_potions[bottle][fluid] = PotionData.new(fluid, bottle)

	var potion_data = {
		"RED:FLASK": {
			"PINK:JUG": null,
			"WHITE:VIAL": null,
			"LIGHT_BLUE:JUG": null,
		}
	}
	var potion_data1 = {
		"PINK:JUG": {
			"RED:FLASK": null,
			"GREEN:VIAL": {
				"PURPLE:FLASK": null,
				"BLUE:VIAL": null,
			},
		}
	}
	var potion_data2 = {
		"YELLOW:JUG": {
			"RED:FLASK": null,
			"GREEN:VIAL": {
				"PURPLE:FLASK": null,
				"BLUE:VIAL": null,
			},
			"BLUE:JUG": null,
			"PINK:JUG": null,
		}
	}

	var potion_data3 = {
		"DARK_GREEN:FLASK": {
			"PINK:VIAL": {
				"YELLOW:FLASK": null,
				"RED:VIAL": null,
				"RED:JUG": null,
			},
			"PURPLE:FLASK": {
				"LIGHT_BLUE:VIAL": null,
				"BLUE:VIAL": null,
			},
			"GREEN:VIAL": {
				"PINK:FLASK": null,
				"BLUE:JUG": null,
			},
			"YELLOW:JUG": null,
		}
	}
	var potion_data4 = {
		"BLACK:FLASK": {
			"RED:JUG": null,
			"GREEN:VIAL": {
				"PINK:JUG": null,
				"PURPLE:VIAL": null,
			},
			"RED:FLASK": {
				"PINK:VIAL": null,
				"GREEN:FLASK": {
					"BLUE:JUG": null,
					"PINK:FLASK": null,
					"RED:VIAL": null,
				},
			},
			"BLUE:VIAL": {
				"LIGHT_BLUE:VIAL": null,
				"BLUE:FLASK": null,
			},
			"DARK_GREEN:FLASK": null,
		}
	}
	var potion_data5 = {
		"WHITE:JUG": {
			"BLACK:FLASK": null,
			"DARK_GREEN:VIAL": {
				"PINK:FLASK": {
					"PINK:VIAL": null,
					"YELLOW:VIAL": {
						"RED:FLASK": null,
						"BLUE:JUG": null,
					},
				},
				"PURPLE:JUG": {
					"YELLOW:FLASK": null,
					"GREEN:VIAL": null,
				},
			},
			"PURPLE:VIAL": {
				"PINK:JUG": null,
				"BLUE:VIAL": null,
			},
			"BLUE:FLASK": {
				"LIGHT_BLUE:VIAL": null,
			},
			"GREEN:JUG": null,
		}
	}
	print("level")
	print(convert_to_potion_data_statements(potion_data, all_potions))
	print("level")
	print(convert_to_potion_data_statements(potion_data1, all_potions))
	print("level")
	print(convert_to_potion_data_statements(potion_data2, all_potions))
	print("level")
	print(convert_to_potion_data_statements(potion_data3, all_potions))
	print("level")
	print(convert_to_potion_data_statements(potion_data4, all_potions))
	print("level")
	print(convert_to_potion_data_statements(potion_data5, all_potions))
	
