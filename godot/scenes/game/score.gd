extends Node2D

var total_score: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_score_label(total_score, 0, false) #Initialize label at start of main game screen


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	

func _on_play_area_popped_bubbles(bubbles: Array[Bubble]) -> void:
	# Adds up the base amount of the bubbles popped
	%ScoreAnimations.play("score_flash")
	var cleared_score: float = 0
	var multiplier: float = 1
	for bubble in bubbles:
		await bubble.BubblePopped
		if bubble.get_powerup() != null:
			if bubble.get_powerup().type == "mult":
				multiplier *= bubble.get_powerup().value
			else:
				bubble.score += bubble.get_powerup().value
		cleared_score += bubble.score
		update_score_label(total_score, cleared_score, multiplier)
		
	# Hold total addition for a second
	await get_tree().create_timer(1).timeout
	update_score_label(total_score, cleared_score, multiplier)
	
	await get_tree().create_timer(1).timeout
	update_score_label(total_score, cleared_score, multiplier) #show how much will be added to total score
	
	# Add cleared score to the total score
	cleared_score *= multiplier
	total_score += cleared_score
	
	# Update score
	await get_tree().create_timer(2).timeout
	update_score_label(total_score, 0, 0)

# Updates the HUD label with the new total score
func update_score_label(score: float, additive: float, multiplicative: float):
	var score_string = str(score)
	var multiplicative_string = str(multiplicative)
	if score > 99_999_99:
		score_string = to_scientific_notation(score)
	if multiplicative > 99_999_99:
		multiplicative_string = to_scientific_notation(multiplicative)
	var score_label =  $HUD/Label
	if additive == 0:
		score_label.text = str("Score:\n") + score_string
	else:
		score_label.text = str("Score:\n") + score_string + " + " + str(additive) + " x " + str(multiplicative_string)
	
	
func to_scientific_notation(number: float) -> String:
	var exponent = floor(log(abs(number)) / log(10))
	var mantissa = number / pow(10, exponent)
	var s = ("%1.2f" % mantissa)
	return s + "e" + str(exponent)


# Adds commas to the total score integer to make the score more readable.
func thousands_sep(number: float, prefix=''):
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
	

func format_large_number(number: float):
	if abs(number) >= 1e10:  # Check if the number exceeds 10 digits
		return String("{:.5e}").format(number)  # Format in scientific notation
	return str(number)  # Return the number as is for smaller values
	
