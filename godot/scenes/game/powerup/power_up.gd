extends Node2D
class_name PowerUp

@export_enum("mult", "flat") var type
@export var value: float

func _ready() -> void:
	var parent_is_bubble: bool = get_parent() is Bubble
	
	if parent_is_bubble: 
		%FlatSprite.visible = false
		%MultSprite.visible = false
	else:
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



 
