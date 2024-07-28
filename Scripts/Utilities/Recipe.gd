extends Node
const sprite_writer_const = preload("res://Scripts/Utilities/SpriteWriter3D.gd")
var sprite_writer = sprite_writer_const.new()

# method return compiled potion 
# method for sprite maker (fluid(color), type)
# method for formula writer (array of sprites) (doesnt need formula, fill array based on ingredient order)

# [orange, purple, yellow] order does not matter
# r + b = purple
# r + g = yellow
# r + y + p = orange
# array object = fluid, type, children
# recipe is childN + ... -> array object (print next line)

# Translates each line to the Paper's UI
func UIRecipeWriter(lines_of_recipe):
	var number_of_results = lines_of_recipe.length()
	var array_of_formula_arrays = []
	
	for formula_line in lines_of_recipe:
		var temp_array = []
		temp_array.append(formula_line.ingredients.pop_front())
		for ingrediant in formula_line.ingredients:
			temp_array.append("+")
			temp_array.append(ingrediant)
		temp_array.append("->")
		array_of_formula_arrays.append(temp_array)
	
	sprite_writer.SpriteWriter(array_of_formula_arrays)
	
# Take in ingrediant or result and returns a sprite
func SpriteWriter(individual_ingrediant):
	var sprite_fluid = individual_ingrediant.fluid
	var sprite_bottle = individual_ingrediant.bottle
	var finished_sprite = null
	#store bottle key to sprite value in dictionary
	#store fluid key to hex value in dictionary
	
	#does magic to choose sprite bottle based on bottle
	#then changes sprite hue to match the fluid color
	# + and -> == black 
	#writes sprite to paper in the environment (PROBABLY the hardest part)
	
	#probably going to have to write the sprites as nodes to the paper.tscn scene so the sprites stay on the paper 
	#https://docs.godotengine.org/en/stable/classes/class_animatedsprite3d.html
	#Use 2d static sprites in 3d space (Create each of the symbol sprites in 2D node then reimport them to a 3D node that is tied to the paper)
	#Overlay a 2d node onto the paper's 3d node? Set bounds to edges of the paper then make a formula that will split the paper up into sprite squares based on the amount of
	#potions inputted into it. 
	#Current Plan:
	#2D node overlay onto paper
	#Use a SpriteWriter script that is linked to the paper object with the 2D node as a child object of the paper 3d node
	#Connect the Recipe Script and SpriteWriter script to allow interaction (e.g based on info from recipe.gd, sprite writer will change the hue of certain sprites)
	#Split the 2D note into square sections with a formula based on the amount of potions inputted
	#Create formula sprites (Flask, Sphere, Tube, +, ->)

