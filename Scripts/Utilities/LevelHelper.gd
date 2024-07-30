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

# Function to process each node in the dictionary
func process_node(data: Dictionary, parent_var: String, potion_count: int) -> Dictionary:
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
		
		statements += "var %s = PotionData.new(FluidType.%s, BottleType.%s)\n" % [potion_var, fluid_str, bottle_str]
		if parent_var != "":
			statements += "%s.add_ingredient(%s)\n" % [parent_var, potion_var]
		
		if typeof(data[key]) == TYPE_DICTIONARY:
			var result = process_node(data[key], potion_var, local_potion_count)
			statements += result["statements"]
			local_potion_count = result["potion_count"]
	
	return {"statements": statements, "potion_count": local_potion_count}

# Function to convert the dictionary into PotionData initialization statements
func convert_to_potion_data_statements(data: Dictionary) -> String:
	var root_key = data.keys()[0]
	var parts = root_key.split(":")
	var fluid_str = parts[0]
	var bottle_str = parts[1]
	
	var root_statements = "var root_potion = PotionData.new(FluidType.%s, BottleType.%s)\n" % [fluid_str, bottle_str]
	var result = process_node(data[root_key], "root_potion", 1)
	
	return root_statements + result["statements"]
	
func _ready():
	var potion_data = {
		"RED:FLASK": {
			"RED:JUG": null,
			"GREEN:VIAL": {
				"PINK:FLASK": null,
				"BLUE:VIAL": null,
			},
			"BLUE:JUG": null,
		}
	}
	
	print(convert_to_potion_data_statements(potion_data))
