extends RefCounted

class_name PotionEquation

enum PotionType {
	BLUE,
	RED,
	GREEN,
	BLACK,
	YELLOW,
	PURPLE,
	BROWN,
	PINK,
}

var result
var ingredients

func _init(result: PotionType, ingredients: Array):
	self.result = result
	self.ingredients = ingredients

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
		
		if ingredient is PotionEquation:
			stats["total_potions"] += 1
			stats["depth"] = max(stats["depth"], level + 1)
			ingredients_str += ingredient.gathering_stats(level + 1, stats)
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

	var result_str = get_indent(level) + PotionType.keys()[result] + ":\n"
	var ingredients_str = ingredients_to_string(level + 1, stats)

	if level == 0:
		var stats_str = "Deepest recursion level: %d\nTotal PotionEquations: %d\nTop-level non-PotionEquation ingredients: %d\nTotal ingredients: %d\nMax ingredients in a potion: %d\n\n" % [stats["depth"], stats["total_potions"], stats["top_level_non_potions"], stats["total_ingredients"], stats["max_ingredients"]]
		return stats_str + result_str + ingredients_str
	else:
		return result_str + ingredients_str

func _to_string() -> String:
	return gathering_stats(0, null)
