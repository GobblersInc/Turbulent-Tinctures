extends Node3D


@onready var cauldron = get_node("/root/PirateShip/Cauldron")

const FluidType = preload("res://Scripts/Utilities/PotionData.gd").FluidType
const BottleType = preload("res://Scripts/Utilities/PotionData.gd").BottleType
const LANTERN_SCRIPT_PATH = "res://Scripts/Models/LanternScript.gd"
const LANTERN_SCENE = "res://Scenes/Models/lantern.tscn"



var required_potion = null
var lost = false
var pouring = false
var tween: Tween


"""
The minimum nesting one can do is 1 - otherwise there wouldn't be any potion equations!
"""



