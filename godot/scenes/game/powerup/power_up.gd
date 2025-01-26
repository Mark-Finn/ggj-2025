extends Node2D
class_name PowerUp

@export_enum("mult", "flat") var type
@export var value: float
var row 
var column

func _ready() -> void:
	if type == "mult":
		%FlatSprite.visible = false
		%MultSprite.visible = true
		value = 2
	else:
		%FlatSprite.visible = true
		%MultSprite.visible = false
		value = 10

func handle_picked_up():
	pass



 
