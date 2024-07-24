extends RefCounted

class_name PotionData

enum PotionType {
	BLUE,
	RED,
	GREEN,
	YELLOW,
	PURPLE,
	PINK,
}

const POTION_TYPE_TO_COLOR = {
	PotionType.BLUE: Color(0, 0, 1, 1),   
	PotionType.RED: Color(1, 0, 0, 1),   
	PotionType.GREEN: Color(0, 1, 0, 1),   
	PotionType.YELLOW: Color(1, 1, 0, 1),   
	PotionType.PURPLE: Color(0.5, 0, 0.5, 1), 
	PotionType.PINK: Color(1, 0.08, 0.58, 1)
}

var result: PotionData = null # equivalent to "parent"
var ingredients: Array = [] # equivalent to "children"
var type: PotionType
var node: Node3D = null

func _init(type):
	self.type = type
	ingredients = []

func add_child(child: PotionData):
	child.result = self
	ingredients.append(child)

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
	
func _collect_leaves(node: PotionData, leaves: Array) -> void:
	if node.is_leaf():
		leaves.append(node)
	else:
		for child in node.ingredients:
			_collect_leaves(child, leaves)

func find_node(type: PotionType, start_node: PotionData = null) -> PotionData:
	if start_node == null:
		start_node = self
	if start_node.type == type:
		return start_node
	for child in start_node.children:
		var found = find_node(type, child)
		if found != null:
			return found
	return null

func get_color():
	return POTION_TYPE_TO_COLOR[self.type]

"""
Below is code for printing out entire trees easily for testing purposes
"""
func get_indent(level: int) -> String:
	var indent = ""
	for i in range(level):
		indent += "    "
	return indent

func ingredients_to_string(level: int, stats) -> String:
	var ingredients_str = ""
	stats["total_ingredients"] += ingredients.size()
	stats["max_ingredients"] = max(stats["max_ingredients"], ingredients.size())

	for ingredient in ingredients:
		if ingredients_str != "":
			ingredients_str += "\n"

		if ingredient is PotionData:
			stats["total_potions"] += 1
			stats["depth"] = max(stats["depth"], level + 1)
			ingredients_str += get_indent(level) + PotionType.keys()[ingredient.type]
			if ingredient.has_ingredients():
				ingredients_str += ":\n"
				ingredients_str += ingredient.ingredients_to_string(level + 1, stats)
			else:
				ingredients_str += ""
		else:
			if level == 1:
				stats["top_level_non_potions"] += 1
			ingredients_str += get_indent(level) + PotionType.keys()[ingredient]

	return ingredients_str

func gathering_stats(level: int, stats) -> String:
	if stats == null:
		stats = {"depth": 0, "total_potions": 0, "top_level_non_potions": 0, "total_ingredients": 0, "max_ingredients": 0}

	if level == 0:
		stats["depth"] = 1  # Start counting depth from 1 for the top-level potion
		stats["total_potions"] = 1  # The top-level potion itself

	var result_str = get_indent(level) + PotionType.keys()[type]
	if has_ingredients():
		result_str += ":\n"
	var ingredients_str = ingredients_to_string(level + 1, stats)

	if level == 0:
		var stats_str = "Deepest recursion level: %d\nTotal PotionEquations: %d\nTop-level non-PotionEquation ingredients: %d\nTotal ingredients: %d\nMax ingredients in a potion: %d\n\n" % [stats["depth"], stats["total_potions"], stats["top_level_non_potions"], stats["total_ingredients"], stats["max_ingredients"]]
		return stats_str + result_str + ingredients_str
	else:
		return result_str + ingredients_str

func _to_string() -> String:
	#return gathering_stats(0, null)
	return PotionType.keys()[type]
