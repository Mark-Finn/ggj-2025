extends Node2D
class_name PowerUp

@export_enum("mult", "flat") var type
@export var value: float

func _ready() -> void:
	var parent_is_bubble: bool = get_parent() is Bubble
	var display = str("0")
	var font_color = Color(0, 0, 0)

	if type != null:
		if type == "mult":
			value = 2
			display = str("x", value)
			font_color = Color(1, 0, 0)
		else:
			%FlatSprite.visible = true
			%MultSprite.visible = false
			value = 10
			display = str("+",value)
			font_color = Color(0, 0, 1)
		
		if parent_is_bubble: 
			%FlatSprite.visible = false
			%MultSprite.visible = false
		else:
			if type == "mult":
				%FlatSprite.visible = false
				%MultSprite.visible = true
			else:
				%FlatSprite.visible = true
				%MultSprite.visible = false
		%Display.set("theme_override_colors/font_color",font_color)
		%Display.text = display
	

func handle_picked_up():
	pass



 
