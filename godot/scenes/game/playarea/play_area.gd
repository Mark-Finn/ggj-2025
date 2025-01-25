extends Node2D


const TETROMINO = preload("res://scenes/game/tetromino/tetromino.tscn")
const PIXELS_PER_UNIT = 32
const NUM_ROWS = 19
var total_score = 0
var bubbles_in_row: Array = []
var index = -1

func _ready() -> void:
	_populate_array()
	_spawn_tetromino()
	

func _populate_array() -> void:
	bubbles_in_row.resize(NUM_ROWS + 1)
	for i in range(bubbles_in_row.size()):
		bubbles_in_row[i] = 0
		

func _spawn_tetromino() -> void:
	var tetromino = TETROMINO.instantiate()
	tetromino.letter = ["I", "O", "T", "J", "L", "S", "Z"].pick_random()
	tetromino.Placed.connect(_on_placed)
	add_child(tetromino)
	
	
func _on_placed(bubbles: Array[Bubble], tetromino_position: Vector2) -> void:
	for bubble in bubbles:
		bubble.position += tetromino_position
		add_child(bubble)
		bubble.set_row(-bubble.position.y / PIXELS_PER_UNIT)
	_check_score(bubbles)
	_spawn_tetromino()
	
	
# Parameter: bubbles is the array of our bubble objects
# Return nothing
func _check_score(bubbles: Array[Bubble]) -> void:
	for bubble in bubbles:
		var row = bubble.get_row()
		if row < NUM_ROWS + 1:
			bubbles_in_row[row] += 1
	for bubble_row in bubbles_in_row:
		if bubble_row >= 10:
			print(bubbles_in_row)
			total_score += 100
			bubbles_in_row[index] = 0
			print(bubbles_in_row)
	print(total_score)
