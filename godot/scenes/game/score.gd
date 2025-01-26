extends Node2D

var total_score = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_score_label() #Initialize label at start of main game screen


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func _on_play_area_popped_bubbles(bubbles: Array[Bubble]) -> void:
	# Adds up the base amount of the bubbles popped
	%ScoreAnimations.play("score_flash")
	var cleared_score = 0
	print(bubbles.size())
	for bubble in bubbles:
		cleared_score += bubble.score
	
	# Calculates the multiplier for bubbles over the mininum needed to pop
	var multiplier = 1
	if bubbles.size() > 10:
		var bubbles_over = bubbles.size() - 10
		multiplier = bubbles_over + 0.5
	cleared_score *= multiplier
	
	# Add cleared score to the total score
	total_score += cleared_score
	update_score_label() #Update score label after score is calculated
	

# Updates the HUD label with the new total score
func update_score_label():
	var score_label =  $HUD/Label
	score_label.text = str("Score:\n") + str(total_score)
	

# Adds commas to the total score integer to make the score more readable.
func thousands_sep(number: int, prefix=''):
	if abs(number) >= 1e10:
		return format_large_number(number)
	number = int(number)
	var string = str(number)
	var mod = string.length() % 3
	var res = ""
	for i in range(0, string.length()):
		if i != 0 && i % 3 == mod:
			res += ","
		res += string[i]
	res = prefix+res
	return res
	

func format_large_number(number: int):
	if abs(number) >= 1e10:  # Check if the number exceeds 10 digits
		return String("{:.5e}").format(number)  # Format in scientific notation
	return str(number)  # Return the number as is for smaller values
	
