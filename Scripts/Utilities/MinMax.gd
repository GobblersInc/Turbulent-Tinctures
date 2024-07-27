# Range.gd
extends RefCounted

class_name MinMax

var min: int
var max: int

# Constructor
func _init(min_value: int, max_value: int):
	min = min_value
	max = max_value
