extends RefCounted

class_name PotionData

enum FluidType {
	BLUE,
	RED,
	GREEN,
	YELLOW,
	PURPLE,
	PINK,
	WHITE,
}

const FLUID_TYPE_TO_COLOR = {
	FluidType.BLUE: Color(0, 0, 1, 1),
	FluidType.RED: Color(1, 0, 0, 1),
	FluidType.GREEN: Color(0, 1, 0, 1),
	FluidType.YELLOW: Color(1, 1, 0, 1),
	FluidType.PURPLE: Color(0.5, 0, 0.5, 1),
	FluidType.PINK: Color(1, 0.08, 0.58, 1),
	FluidType.WHITE: Color(1, 1, 1, 1),
}

enum BottleType {
	VIAL,
	FLASK,
	JUG,
}

var result: PotionData = null # equivalent to "parent"
var ingredients: Array = [] # equivalent to "children"

var fluid: FluidType
var bottle: BottleType

var node: Node3D = null
var position: Vector3

func _init(fluid: FluidType, bottle: BottleType):
	self.fluid = fluid
	self.bottle = bottle
	ingredients = []

func add_ingredient(ingredient: PotionData):
	ingredient.result = self
	ingredients.append(ingredient)

func remove_child(child: PotionData):
	if child in ingredients:
		ingredients.erase(child)
		child.result = null

func get_siblings() -> Array:
	if result == null:
		return []
	var siblings = result.ingredients.duplicate()
	return siblings

func has_ingredients() -> bool:
	return ingredients.size() > 0

func is_root() -> bool:
	return result == null

func is_leaf() -> bool:
	return ingredients.size() == 0

func get_all_leaves() -> Array:
	var leaves = []
	_collect_leaves(self, leaves)
	return leaves

func _collect_leaves(potion: PotionData, leaves: Array) -> void:
	if potion.is_leaf():
		leaves.append(potion)
	else:
		for ingredient in potion.ingredients:
			_collect_leaves(ingredient, leaves)

func find_node(fluid: FluidType, bottle: BottleType, start_node: PotionData = null) -> PotionData:
	if start_node == null:
		start_node = self
	if start_node.fluid == fluid and start_node.bottle == bottle:
		return start_node
	for child in start_node.children:
		var found = find_node(fluid, bottle, child)
		if fluid != null and bottle != null:
			return found
	return null

func get_color():
	return FLUID_TYPE_TO_COLOR[self.fluid]

func get_all_non_leaves() -> Array:
	var non_leaves = []
	_collect_non_leaves(self, non_leaves)
	return non_leaves

func _collect_non_leaves(potion: PotionData, non_leaves: Array) -> void:
	if not potion.is_leaf():
		non_leaves.append(potion)
		for ingredient in potion.ingredients:
			_collect_non_leaves(ingredient, non_leaves)

# Custom comparison function
static func compare_potion_data(a: PotionData, b: PotionData) -> int:
	return hash(a) < hash(b)
	
	#if a.bottle == b.bottle:
		#return a.fluid < b.fluid
	#return a.bottle < b.bottle

# Sort function for an array of PotionData objects
static func sort_potion_data_array(array: Array) -> Array:
	var sorted_array = array.duplicate()
	sorted_array.sort_custom(compare_potion_data)

	return sorted_array

"""
Below is code for printing out entire trees easily for testing purposes
"""
func get_indent(level: int) -> String:
	var indent = ""
	for i in range(level):
		indent += "    "
	return indent

func ingredients_to_string(level: int, ingredients: Array, stats: Dictionary) -> String:
	var ingredients_str = ""
	stats["total_ingredients"] += ingredients.size()
	stats["max_ingredients"] = max(stats["max_ingredients"], ingredients.size())

	for ingredient in ingredients:
		if ingredients_str != "":
			ingredients_str += "\n"

		if ingredient != null:
			stats["total_potions"] += 1
			stats["depth"] = max(stats["depth"], level + 1)
			ingredients_str += get_indent(level) + str(ingredient)
			
			if ingredient.ingredients != []:
				ingredients_str += ":\n"
				ingredients_str += ingredients_to_string(level + 1, ingredient.ingredients, stats)
			else:
				ingredients_str += ""
		else:
			ingredients_str += get_indent(level) + FluidType.keys()[ingredient]

	return ingredients_str

func print_game_info(show_stats: bool) -> void:
	var stats = {"depth": 0, "total_potions": 0, "total_ingredients": 0, "max_ingredients": 0}

	var result_str = str(self)
	if self.ingredients != []:
		result_str += ":\n"
	var ingredients_str = ingredients_to_string(1, self.ingredients, stats)

	if show_stats:
		var stats_str = "Deepest recursion level: %d\nTotal PotionEquations: %d\nTotal ingredients: %d\nMax ingredients in a potion: %d\n\n" % [stats["depth"], stats["total_potions"], stats["total_ingredients"], stats["max_ingredients"]]
		print(stats_str + result_str + ingredients_str + "\n")
	else:
		print(result_str + ingredients_str + "\n")


func _to_string() -> String:
	#return gathering_stats(0, null)
	return FluidType.keys()[fluid] + ":" + BottleType.keys()[bottle]
