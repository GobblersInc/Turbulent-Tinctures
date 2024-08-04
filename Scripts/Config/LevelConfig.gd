extends Node

const FluidType = preload("res://Scripts/Utilities/PotionData.gd").FluidType
const BottleType = preload("res://Scripts/Utilities/PotionData.gd").BottleType

var LEVEL_CONFIG = [
	{
		"potion": level_one_potion,
		"flicker_probability": 1,
		"light_out_duration": 3,
		"check_interval": 8,
		"lights_out_cooldown": 10,
		"light_on_or_off": true,
		"game_timer": 30
	},
	{
		"potion": level_two_potion,
		"flicker_probability": 0.3,
		"light_out_duration": 8,
		"check_interval": 3,
		"lights_out_cooldown": 8,
		"light_on_or_off": true,
		"game_timer": 30
	},
	{
		"potion": level_three_potion,
		"flicker_probability": 0.3,
		"light_out_duration": 8,
		"check_interval": 3,
		"lights_out_cooldown": 6,
		"light_on_or_off": true,
		"game_timer": 60
	},
	{
		"potion": level_four_potion,
		"flicker_probability": 0.3,
		"light_out_duration": 8,
		"check_interval": 3,
		"lights_out_cooldown": 6,
		"light_on_or_off": true,
		"game_timer": 60
	},
	{
		"potion": level_five_potion,
		"flicker_probability": 0.3,
		"light_out_duration": 8,
		"check_interval": 3,
		"lights_out_cooldown": 6,
		"light_on_or_off": true,
		"game_timer": 70
	},
	{
		"potion": level_six_potion,
		"flicker_probability": 0.3,
		"light_out_duration": 8,
		"check_interval": 3,
		"lights_out_cooldown": 6,
		"light_on_or_off": true,
		"game_timer": 75
	},
]

func level_one_potion(all_potions):
	var potion_0 = all_potions[BottleType.FLASK][FluidType.RED]
	var potion_1 = all_potions[BottleType.JUG][FluidType.PINK]
	potion_0.add_ingredient(potion_1)
	var potion_2 = all_potions[BottleType.VIAL][FluidType.WHITE]
	potion_0.add_ingredient(potion_2)
	var potion_3 = all_potions[BottleType.JUG][FluidType.LIGHT_BLUE]
	potion_0.add_ingredient(potion_3)

	return potion_0

func level_two_potion(all_potions):
	var potion_0 = all_potions[BottleType.JUG][FluidType.PINK]
	var potion_1 = all_potions[BottleType.FLASK][FluidType.RED]
	potion_0.add_ingredient(potion_1)
	var potion_2 = all_potions[BottleType.VIAL][FluidType.GREEN]
	potion_0.add_ingredient(potion_2)
	var potion_3 = all_potions[BottleType.FLASK][FluidType.PURPLE]
	potion_2.add_ingredient(potion_3)
	var potion_4 = all_potions[BottleType.VIAL][FluidType.BLUE]
	potion_2.add_ingredient(potion_4)

	return potion_0

func level_three_potion(all_potions):
	var potion_0 = all_potions[BottleType.JUG][FluidType.YELLOW]
	var potion_1 = all_potions[BottleType.FLASK][FluidType.RED]
	potion_0.add_ingredient(potion_1)
	var potion_2 = all_potions[BottleType.VIAL][FluidType.GREEN]
	potion_0.add_ingredient(potion_2)
	var potion_3 = all_potions[BottleType.FLASK][FluidType.PURPLE]
	potion_2.add_ingredient(potion_3)
	var potion_4 = all_potions[BottleType.VIAL][FluidType.BLUE]
	potion_2.add_ingredient(potion_4)
	var potion_5 = all_potions[BottleType.JUG][FluidType.BLUE]
	potion_0.add_ingredient(potion_5)
	var potion_6 = all_potions[BottleType.JUG][FluidType.PINK]
	potion_0.add_ingredient(potion_6)

	return potion_0

func level_four_potion(all_potions):
	var potion_0 = all_potions[BottleType.FLASK][FluidType.DARK_GREEN]
	var potion_1 = all_potions[BottleType.VIAL][FluidType.PINK]
	potion_0.add_ingredient(potion_1)
	var potion_2 = all_potions[BottleType.FLASK][FluidType.YELLOW]
	potion_1.add_ingredient(potion_2)
	var potion_3 = all_potions[BottleType.VIAL][FluidType.RED]
	potion_1.add_ingredient(potion_3)
	var potion_4 = all_potions[BottleType.JUG][FluidType.RED]
	potion_1.add_ingredient(potion_4)
	var potion_5 = all_potions[BottleType.FLASK][FluidType.PURPLE]
	potion_0.add_ingredient(potion_5)
	var potion_6 = all_potions[BottleType.VIAL][FluidType.LIGHT_BLUE]
	potion_5.add_ingredient(potion_6)
	var potion_7 = all_potions[BottleType.VIAL][FluidType.BLUE]
	potion_5.add_ingredient(potion_7)
	var potion_8 = all_potions[BottleType.VIAL][FluidType.GREEN]
	potion_0.add_ingredient(potion_8)
	var potion_9 = all_potions[BottleType.FLASK][FluidType.PINK]
	potion_8.add_ingredient(potion_9)
	var potion_10 = all_potions[BottleType.JUG][FluidType.BLUE]
	potion_8.add_ingredient(potion_10)
	var potion_11 = all_potions[BottleType.JUG][FluidType.YELLOW]
	potion_0.add_ingredient(potion_11)

	return potion_0

func level_five_potion(all_potions):
	var potion_0 = PotionData.new(FluidType.BLACK, BottleType.FLASK)
	var potion_1 = PotionData.new(FluidType.RED, BottleType.JUG)
	potion_0.add_ingredient(potion_1)
	var potion_2 = PotionData.new(FluidType.GREEN, BottleType.VIAL)
	potion_0.add_ingredient(potion_2)
	var potion_3 = PotionData.new(FluidType.PINK, BottleType.JUG)
	potion_2.add_ingredient(potion_3)
	var potion_4 = all_potions[BottleType.VIAL][FluidType.PURPLE]
	potion_2.add_ingredient(potion_4)
	var potion_5 = PotionData.new(FluidType.RED, BottleType.FLASK)
	potion_0.add_ingredient(potion_5)
	var potion_6 = PotionData.new(FluidType.PINK, BottleType.VIAL)
	potion_5.add_ingredient(potion_6)
	var potion_7 = PotionData.new(FluidType.GREEN, BottleType.FLASK)
	potion_5.add_ingredient(potion_7)
	var potion_8 = PotionData.new(FluidType.BLUE, BottleType.JUG)
	potion_7.add_ingredient(potion_8)
	var potion_9 = PotionData.new(FluidType.PINK, BottleType.FLASK)
	potion_7.add_ingredient(potion_9)
	var potion_10 = all_potions[BottleType.VIAL][FluidType.RED]
	potion_7.add_ingredient(potion_10)
	var potion_11 = all_potions[BottleType.VIAL][FluidType.BLUE]
	potion_0.add_ingredient(potion_11)
	var potion_12 = all_potions[BottleType.VIAL][FluidType.LIGHT_BLUE]
	potion_11.add_ingredient(potion_12)
	var potion_13 = all_potions[BottleType.FLASK][FluidType.BLUE]
	potion_11.add_ingredient(potion_13)
	var potion_14 = all_potions[BottleType.FLASK][FluidType.DARK_GREEN]
	potion_0.add_ingredient(potion_14)

	return potion_0

func level_six_potion(all_potions):
	var potion_0 = all_potions[BottleType.JUG][FluidType.WHITE]
	var potion_1 = all_potions[BottleType.FLASK][FluidType.BLACK]
	potion_0.add_ingredient(potion_1)
	var potion_2 = all_potions[BottleType.VIAL][FluidType.DARK_GREEN]
	potion_0.add_ingredient(potion_2)
	var potion_3 = all_potions[BottleType.FLASK][FluidType.WHITE]
	potion_2.add_ingredient(potion_3)
	var potion_4 = PotionData.new(FluidType.PINK, BottleType.VIAL)
	potion_3.add_ingredient(potion_4)
	var potion_5 = all_potions[BottleType.VIAL][FluidType.YELLOW]
	potion_3.add_ingredient(potion_5)
	var potion_6 = all_potions[BottleType.FLASK][FluidType.RED]
	potion_5.add_ingredient(potion_6)
	var potion_7 = all_potions[BottleType.JUG][FluidType.BLUE]
	potion_5.add_ingredient(potion_7)
	var potion_8 = all_potions[BottleType.JUG][FluidType.PURPLE]
	potion_2.add_ingredient(potion_8)
	var potion_9 = all_potions[BottleType.FLASK][FluidType.YELLOW]
	potion_8.add_ingredient(potion_9)
	var potion_10 = all_potions[BottleType.VIAL][FluidType.GREEN]
	potion_8.add_ingredient(potion_10)
	var potion_11 = all_potions[BottleType.VIAL][FluidType.PURPLE]
	potion_0.add_ingredient(potion_11)
	var potion_12 = all_potions[BottleType.JUG][FluidType.PINK]
	potion_11.add_ingredient(potion_12)
	var potion_13 = all_potions[BottleType.VIAL][FluidType.BLUE]
	potion_11.add_ingredient(potion_13)
	var potion_14 = all_potions[BottleType.FLASK][FluidType.BLUE]
	potion_0.add_ingredient(potion_14)
	var potion_15 = all_potions[BottleType.VIAL][FluidType.LIGHT_BLUE]
	potion_14.add_ingredient(potion_15)
	var potion_16 = all_potions[BottleType.JUG][FluidType.GREEN]
	potion_0.add_ingredient(potion_16)

	return potion_0
