extends Node
class_name TetrominoState

signal Transition

var tetromino: Tetromino
var game_clock: Timer

var HOLD_MOVE_PERIOD = 0.15

static var _next_left_time: float = 0
static var _next_right_time: float = 0
static var _next_up_time: float = 0


func process(delta: float) -> void:
	_next_left_time -= delta
	_next_right_time -= delta
	_next_up_time -= delta
	
	if Input.is_action_just_pressed("rotate_left"):
		tetromino.process_rotate(90)
		return
	if Input.is_action_just_pressed("rotate_right"):
		tetromino.process_rotate(270)	
		return
	if Input.is_action_just_pressed("rotate_180") && tetromino.letter != "I":
		tetromino.process_rotate(180)
		return
	
	var left_pressed = Input.is_action_pressed("left")
	var right_pressed = Input.is_action_pressed("right")
	var up_pressed = Input.is_action_pressed("up")
	var slam_pressed = Input.is_action_pressed("slam")
	
	if left_pressed && right_pressed:
		return
	elif slam_pressed:
		tetromino.slam_time(Vector2.UP)
	elif left_pressed && (_next_left_time < 0 || Input.is_action_just_pressed("left")):
		if tetromino.try_move(Vector2.LEFT):
			_next_left_time = HOLD_MOVE_PERIOD
	elif right_pressed && (_next_right_time < 0 || Input.is_action_just_pressed("right")):
		if tetromino.try_move(Vector2.RIGHT):
			_next_right_time = HOLD_MOVE_PERIOD
			
	if up_pressed && (_next_up_time < 0 || Input.is_action_just_pressed("up")):
		if tetromino.try_move(Vector2.UP):
			game_clock.stop()
			game_clock.start()
			_next_up_time = HOLD_MOVE_PERIOD
		
			
func enter():
	pass
	
	
func exit():
	pass
	

func game_tick_update():
	pass
