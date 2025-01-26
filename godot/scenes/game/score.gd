extends Node2D

var total_score = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_score_label(total_score, 0, false) #Initialize label at start of main game screen


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	

func _on_play_area_popped_bubbles(bubbles: Array[Bubble]) -> void:
	# Adds up the base amount of the bubbles popped
	%ScoreAnimations.play("score_flash")
	var cleared_score = 0
	var multiplier = 1
	for bubble in bubbles:
		await bubble.BubblePopped
		if bubble.get_powerup() != null:
			if bubble.get_powerup().type == "mult":
				multiplier += bubble.get_powerup().value
			else:
				bubble.score += bubble.get_powerup().value
		cleared_score += bubble.score
		update_score_label(total_score + cleared_score, cleared_score, true)
		
	# Calculates the multiplier for bubbles over the mininum needed to pop
	if bubbles.size() > 10:
		multiplier += (bubbles.size() - 10) + 1
	cleared_score *= multiplier
	print(multiplier)
	
	# wait to let user see multiplier
	update_score_label(total_score, multiplier, false)
	await get_tree().create_timer(.3).timeout
	
	# Add cleared score to the total score
	total_score += cleared_score
	
	# Update score
	update_score_label(total_score, cleared_score, true) #show total cleared score
	await get_tree().create_timer(.5).timeout
	update_score_label(total_score, 0, false)

# Updates the HUD label with the new total score
func update_score_label(score: int, increase: float, is_addition: bool):
	
	#start animation
	var animation_player = $HUD/AnimationPlayer
	animation_player.play("float_bubble")
	
	 #start score label
	var score_label =  $HUD/AnimationPlayer/Label
	if increase == 0:
		score_label.text = str(score)
	elif is_addition:
		score_label.text = str(score) + str(" + ") + str(increase)
	elif !is_addition:
		score_label.text = str(score) + str(" x ") + str(increase)

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
	
