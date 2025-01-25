extends TetrominoState
class_name Coyote

@export var maximum_entries: int = 3
@export var max_coyote_ticks: int = 3
@export var min_coyote_ticks: int = 1

var coyote_entries := 0
var total_ticks := 1
var ticks_since_last_rotation := 1


func enter():
	coyote_entries += 1
	if coyote_entries > maximum_entries:
		Transition.emit(self, 'Placed')

func exit():
	total_ticks = 1
	ticks_since_last_rotation = 1
	
	
func process(delta: float, game_clock: Timer):
	super.process(delta, game_clock)
	
	var is_rotated = Input.is_action_just_pressed("rotate_left") \
		|| Input.is_action_just_pressed("rotate_right") \
		|| Input.is_action_just_pressed("rotate_180")
	
	if is_rotated:
		ticks_since_last_rotation = 0
	

func game_tick_update():
	total_ticks += 1
	ticks_since_last_rotation += 1
	
	if not tetromino.is_up_blocked():
		Transition.emit(self, 'Rising')
		return
	
	if ticks_since_last_rotation > min_coyote_ticks || total_ticks > max_coyote_ticks:
		Transition.emit(self, 'Placed')
		return
