extends Node2D


const TETROMINO = preload("res://scenes/game/tetromino/tetromino.tscn")
const PIXELS_PER_UNIT = 32
const NUM_ROWS = 19
var total_score

func _ready() -> void:
	_spawn_tetromino()
	
	
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
	get_score(bubbles)
	_spawn_tetromino()
	
	
func get_score(bubbles: Array[Bubble]) -> void:
	var bubbles_in_row: Array = []
	bubbles_in_row.resize(NUM_ROWS)
	for i in range(bubbles_in_row.size()):
		bubbles_in_row[i] = 0
	for bubble in bubbles:
		var row = bubble.get_row()
		print(row)
		print(bubbles_in_row)
		#bubbles_in_row[row] += 1
	for row in bubbles_in_row:
		if row == 10:
			print("YOU SCORED", 100)
		else:
			print("NO SCORE")
