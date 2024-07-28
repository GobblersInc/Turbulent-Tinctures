extends Area3D
@onready var game_manager = $"../../Managers/GameManager"

#read data
#create individual sprite 3d model for each symbol
#repeat until bounds are hit 
#new line 
# Called when the node enters the scene tree for the first time.

var sprite_path = "res://Assets/Sprites/FormulaSprites/"
var flask_image = sprite_path + "Flask.PNG"
var sphere_image = sprite_path + "Sphere.PNG"
var tube_image = sprite_path + "Tube.PNG"
var plus_image = sprite_path + "Plus.PNG"
var arrow_image = sprite_path + "Arrow.PNG"

const FluidType = preload("res://Scripts/Utilities/PotionData.gd").FluidType
const BottleType = preload("res://Scripts/Utilities/PotionData.gd").BottleType

const POTION_SCENES = {
	BottleType.VIAL: "res://Scenes/Models/vial_potion.tscn",
	BottleType.FLASK: "res://Scenes/Models/flask_potion.tscn",
	BottleType.JUG: "res://Scenes/Models/jug_potion.tscn",
}

func _ready():
	game_manager.Recipe.connect(SpriteWriter)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#write up a node cleanup process, then retrigger the sprite writer 
	pass
	
func IndividualWrite(potion, pos_x, pos_y, x_bound, y_bound, start_x, start_z):
	print(potion, " - ", pos_x, " - ", pos_y, " - ", x_bound, " - ", y_bound)
	var sprite_temp = Sprite3D.new()
	var scale_value = x_bound * y_bound

#var image = Image.load_from_file("res://icon.svg")
#var texture = ImageTexture.create_from_image(image)
#$Sprite2D.texture = texture

	#STILL NEED TO CHECK FOR BOTTLE COLOR
	if typeof(potion) == TYPE_OBJECT:
		if potion.bottle == BottleType.VIAL:
			var image = Image.load_from_file(tube_image)
			var texture = ImageTexture.create_from_image(image)
			sprite_temp.texture = texture
		if potion.bottle == BottleType.FLASK:
			var image = Image.load_from_file(flask_image)
			var texture = ImageTexture.create_from_image(image)
			sprite_temp.texture = texture
		if potion.bottle == BottleType.JUG:
			var image = Image.load_from_file(sphere_image)
			var texture = ImageTexture.create_from_image(image)
			sprite_temp.texture = texture
		sprite_temp.position = Vector3((start_z+0.5) + (-pos_y * y_bound), 0.08667, (start_x+0.5) + (-pos_x * x_bound)) 
		sprite_temp.scale = Vector3(x_bound, x_bound, x_bound)
		sprite_temp.rotation_degrees = Vector3(-90, 90, 0) 
		
		add_child(sprite_temp)
		print(sprite_temp.position, " - sprite added!")
	else:
		if potion == "+":
			var image = Image.load_from_file(plus_image)
			var texture = ImageTexture.create_from_image(image)
			sprite_temp.texture = texture
		if potion == "=>":
			var image = Image.load_from_file(arrow_image)
			var texture = ImageTexture.create_from_image(image)
			sprite_temp.texture = texture
		sprite_temp.position = Vector3((start_z+0.5) + (-pos_y * y_bound), 0.08667, (start_x+0.5) + (-pos_x * x_bound))
		sprite_temp.scale = Vector3(x_bound, x_bound, x_bound)
		sprite_temp.rotation_degrees = Vector3(-90, 90, 0) 
		
		add_child(sprite_temp)
		print(sprite_temp.position, " - sprite added!")
		
	#CHECK BOUNDS AND OTHER FOR VECTOR VALUES (First, last, next, how many formulas?)
	
	#x, y, z
	#sprite_temp.position = Vector3(pos_x * x_bound, pos_y * y_bound, 0) #translate to start left to right
	#sprite_temp.scale = Vector3(x_bound, y_bound, 1)
	#sprite_temp.rotation_degrees = Vector3() #set to facing up
	#scale should change based on how many formulas there are
	
	# TO DO LIST:
	# Change hue of bottles to match fluid color
	# Fix scaling to look better
	# Test cases where there are multiple formula lines
	# FOR THE LOVE OF GOD FIX THE VARIABLE NAMES AND WHERE VALUES BELONG/GO (Do not look at x and z anyone but Tallon, it will make 0 sense)
	

func SpriteWriter(array_of_potions:Array):
	var sprite_area = $CollisionShape3D
	var sprite_area_limits = sprite_area.shape.size
	var size_x = sprite_area_limits.x
	var size_z = sprite_area_limits.z
	var starting_z_point = size_x/2
	var starting_x_point = size_z/2
	
	print(sprite_area_limits, sprite_area.position)
	print(starting_x_point, " - ",  starting_z_point)
	
	var recipe_size = len(array_of_potions)
	var sprite_z_bound = (size_x/recipe_size)
	var counter_y = 1
	
	#calculate size values here, input into write as vector values

	for formula_line in array_of_potions:
		var array_of_ingredients = formula_line.ingredients
		var length_of_ingredients = len(formula_line.ingredients) * 2 + 1 # (num of ingre potions == num of operators) so *2 +  1x result potion, look into using this for sprite pos
		var sprite_x_bound = (size_z/length_of_ingredients)
		
		print(formula_line)
		print(array_of_ingredients)
		
		var first_sprite = array_of_ingredients.pop_front()
		var counter_x = 1
		IndividualWrite(first_sprite, counter_x, counter_y, sprite_x_bound, sprite_z_bound, starting_x_point, starting_z_point)
		counter_x += 1
		for sprite in array_of_ingredients:
			var next_sprite = sprite
			IndividualWrite("+", counter_x, counter_y, sprite_x_bound, sprite_z_bound, starting_x_point, starting_z_point)
			IndividualWrite(next_sprite, counter_x+1, counter_y, sprite_x_bound, sprite_z_bound, starting_x_point, starting_z_point)
			counter_x += 2
		IndividualWrite("=>", counter_x, counter_y, sprite_x_bound, sprite_z_bound, starting_x_point, starting_z_point)
		IndividualWrite(formula_line, counter_x+1, counter_y, sprite_x_bound, sprite_z_bound, starting_x_point, starting_z_point)
		counter_y += 1

#func UIRecipeWriter(lines_of_recipe):
	#var number_of_results = lines_of_recipe.length()
	#var array_of_formula_arrays = []
	#
	#for formula_line in lines_of_recipe:
		#var temp_array = []
		#temp_array.append(formula_line.ingredients.pop_front())
		#for ingrediant in formula_line.ingredients:
			#temp_array.append("+")
			#temp_array.append(ingrediant)
		#temp_array.append("->")
		#array_of_formula_arrays.append(temp_array)
	#
	#sprite_writer.SpriteWriter(array_of_formula_arrays)
