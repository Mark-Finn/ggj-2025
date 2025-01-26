extends TetrominoState
class_name Rising


func game_tick_update():
	super.game_tick_update()
	if tetromino.is_position_blocked(Vector2(0, -2)) || tetromino.is_position_blocked(Vector2.UP):
		Transition.emit(self, "Coyote")
	tetromino.try_move(Vector2.UP)
	
