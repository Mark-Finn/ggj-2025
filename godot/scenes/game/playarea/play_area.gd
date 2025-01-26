extends Node2D
class_name PlayArea


const CONSECUTIVE_BUBBLE_POP = 10.0

signal PoppedBubbles


# Constanst
const TETROMINO = preload("res://scenes/game/tetromino/tetromino.tscn")
const POWERUP = preload("res://scenes/game/powerup/power_up.tscn")
const PIXELS_TO_UNITS = 32
const NUM_ROWS = 24


 
# Global Variables
var bubble_grid: Dictionary = {}
var spawn_pos: Vector2i
var total_score = 0
var index = -1
var tetronimo_max = 6
var powerup_grid: Dictionary = {}



func is_position_blocked(pos: Vector2) -> bool:
	var pos_i = _to_vector2i(pos)
	return !bubble_grid.has(pos_i.y) \
		|| !bubble_grid[pos_i.y].has(pos_i.x) \
		|| bubble_grid[pos_i.y][pos_i.x] != null
		
func get_position_powerup(pos: Vector2) -> PowerUp:
	var pos_i = _to_vector2i(pos)
	var has_powerup = !powerup_grid.has(pos_i.y) \
		|| !powerup_grid[pos_i.y].has(pos_i.x) \
		|| powerup_grid[pos_i.y][pos_i.x] != null
	if not has_powerup: 
		return null
	var temp = powerup_grid[pos_i.y][pos_i.x]
	powerup_grid[pos_i.y][pos_i.x] = null
	remove_child(temp)
	return temp
		
		
func _to_vector2i(vec: Vector2) -> Vector2i:
	return Vector2i(int(round(vec.x)), int(round(vec.y)))


func _ready() -> void:
	for row in %Grid.height:
		bubble_grid[row] = {}
		powerup_grid[row] = {}
		for col in %Grid.width:
			bubble_grid[row][col] = null
			powerup_grid[row][col] = null
			
	spawn_pos = Vector2i(int(%Grid.width / 2), %Grid.height - 5) # todo fix
	_spawn_tetromino()
	_spawn_powerup()
	
func _spawn_tetromino() -> void:
	var tetromino = TETROMINO.instantiate()
	tetromino.position = spawn_pos * PIXELS_TO_UNITS
	var tetromino_selected = int(randf_range(0,tetronimo_max+1))
	tetromino.letter = Tetromino.TETROMINO_MAP.keys()[tetromino_selected] #picks random letter from tetromino maps
	if tetronimo_max < Tetromino.TETROMINO_MAP.size():
		tetronimo_max += .25
	tetromino.Placed.connect(_on_placed)
	add_child(tetromino)
	
func _spawn_powerup() -> void:
	var powerup = POWERUP.instantiate()
	var spawn_spot = Vector2i(int(%Grid.width / 2), %Grid.height - 10) #add pick random empty spot with no powerup
	powerup.position =  spawn_spot * PIXELS_TO_UNITS
	var powerup_selected = randf()
	if powerup_selected > .5:
		powerup.type = "mult"
	else: powerup.type = "flat"
	var power_row := int(powerup.position.y / PIXELS_TO_UNITS)
	var power_col := int(powerup.position.x / PIXELS_TO_UNITS)
	powerup.row = power_row
	powerup.column = power_col
	#assert(powerup_grid[power_row][power_col] == null)
	powerup_grid[power_row][power_col] = powerup
	add_child(powerup)
	
func _on_placed(bubbles: Array[Bubble], tetromino_position: Vector2) -> void:
	var num_bubbles = 0
	var changed_rows: Dictionary = {}
	for bubble in bubbles:
		num_bubbles += 1
		bubble.position += tetromino_position
		add_child(bubble)
		var row := int(bubble.position.y / PIXELS_TO_UNITS)
		var col := int(bubble.position.x / PIXELS_TO_UNITS)
		bubble.row = row
		bubble.column = col
		assert(bubble_grid[row][col] == null)
		bubble_grid[row][col] = bubble
		changed_rows[row] = true
	await _handle_placed_bubbles(changed_rows.keys())
	_spawn_tetromino()
	

func _handle_placed_bubbles(changed_rows: Array) -> void:
	var consecutive_bubbles_pop = min(%Grid.width, CONSECUTIVE_BUBBLE_POP)
	
	changed_rows.sort()
	var popped_bubbles: Array[Vector2i] = []
	for row in changed_rows:
		var cols = bubble_grid[row].keys()
		cols.sort()
		var cols_with_bubbles: Array[int] = []
		for col in cols:
			var icol: int = int(col)
			if bubble_grid[row][icol] != null:
				cols_with_bubbles.append(icol)
		for popped_col in _get_consecutive(cols_with_bubbles, consecutive_bubbles_pop):
			popped_bubbles.append(Vector2i(row, popped_col))
	await _handle_popped_bubbles(popped_bubbles)


func _get_consecutive(sorted_arr: Array[int], _min: int) -> Array[int]:
	var consecutive_numbers: Array[int] = [sorted_arr[0]]

	for i in range(1, sorted_arr.size()):
		if sorted_arr[i] == sorted_arr[i - 1] + 1:
			consecutive_numbers.append(sorted_arr[i])
		elif consecutive_numbers.size() >= _min:
			return consecutive_numbers
		else:
			consecutive_numbers = [sorted_arr[i]] 
			
	const EMPTY: Array[int] = []
	return consecutive_numbers if consecutive_numbers.size() >= _min else EMPTY

	
# note bubbles will be sorted from top left to bottom right
func _handle_popped_bubbles(bubbles_positions: Array[Vector2i]) -> void:
	if not bubbles_positions:
		return
		
	var bubbles: Array[Bubble] = []
	var bubble_shifts: Dictionary = {} 
	for bubbles_position in bubbles_positions:
		assert(bubble_grid[bubbles_position.x][bubbles_position.y] != null)
		bubbles.append(bubble_grid[bubbles_position.x][bubbles_position.y])
		bubble_grid[bubbles_position.x][bubbles_position.y] = null
		
		for down in range(1, %Grid.height - bubbles_position.x):
			var below_position = bubbles_position + Vector2i(down, 0)
			if not bubble_shifts.has(below_position):
				bubble_shifts[below_position] = 0
			bubble_shifts[below_position] += 1
			
	var ordinal: int = 0
	for bubble in bubbles:
		bubble.pop(ordinal)
		ordinal += 1
	
	PoppedBubbles.emit(bubbles)
	
	await get_tree().create_timer(ordinal * .03).timeout #fix
	
	var finished_falling = false
	for row in range(0,  %Grid.height):
		for col in range(0,  %Grid.width):
			var b: Bubble = bubble_grid[row][col]
			var key = Vector2i(row, col)
			if b == null || !bubble_shifts.has(key):
				continue
			var shift = bubble_shifts[key]
			var new_pos = b.position
			new_pos.y -= shift * PIXELS_TO_UNITS
			finished_falling = b.change_position_after_pop(new_pos)
			bubble_grid[row - shift][col] = b
			bubble_grid[row][col] = null
			
	if finished_falling:
		await finished_falling
