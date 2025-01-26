extends Control

# Dictionary to store references to the key labels
var key_labels = {}

func _ready():
# Populate the key_labels dictionary with Label nodes
	for label in %Keys.get_children():
		if label is Label:
			key_labels[label.name] = label


func _input(event):
	var keep_highlights: Dictionary = {}
	if event is InputEventKey:
		for key in key_labels.keys():
			var label: Label = key_labels[key]
			if Input.is_key_pressed(event.keycode) and OS.get_keycode_string(event.keycode) == key:
				keep_highlights[key] = true
				flash_key(label)
		
		for key in key_labels.keys():
			if not keep_highlights.has(key):
				remove_highlight(key_labels[key])

func flash_key(label: Label):
	label.add_theme_color_override("font_color", Color(0, 128, 128)) 

	
func remove_highlight(label: Label):
	label.add_theme_color_override("font_color", Color(1, 1, 1)) 
