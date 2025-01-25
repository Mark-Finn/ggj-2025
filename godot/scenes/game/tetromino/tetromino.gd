extends Node2D
class_name Tetromino


signal Placed


@export_enum("I", "O", "T", "J", "L", "S", "Z") var letter: String = "T"


const PIXELS_PER_UNIT = 32

const TETROMINO_COLORS = {
	"I": Color(0, 0.941, 0.941),
	"O": Color(0.902, 0.827, 0),
	"T": Color(0.627, 0, 0.941),
	"J": Color(0, 0.51, 0.914),
	"L": Color(0.941, 0.627, 0),
	"Z": Color(0.941, 0, 0),
	"S": Color(0, 0.941, 0),
}

const TETROMINO_MAP = {
	"I": [Vector2.LEFT, Vector2.ZERO, Vector2.RIGHT, Vector2(2, 0)],
	"O": [Vector2.ZERO, Vector2.UP, Vector2(1, -1), Vector2.RIGHT],
	"T": [Vector2.LEFT, Vector2.ZERO, Vector2.RIGHT,Vector2.DOWN],
	"J": [Vector2.LEFT, Vector2.ZERO, Vector2.RIGHT, Vector2(-1, -1)],
	"L": [Vector2.LEFT, Vector2.ZERO, Vector2.RIGHT, Vector2(1, -1)],
	"Z": [Vector2.ZERO, Vector2.RIGHT, Vector2.UP, Vector2(-1, -1)],
	"S": [Vector2.ZERO, Vector2.LEFT, Vector2.UP, Vector2(1, -1)],
}

const BUBBLE := preload("res://scenes/game/tetromino/bubble.tscn")

var _current_rotation: int = 0

const _MOVE_COOLDOWN: float = 0.07
var _time_till_move: float = 0.0

func _ready() -> void:
	assert(letter in TETROMINO_MAP and letter in TETROMINO_COLORS)
	var color = TETROMINO_COLORS[letter]
	for pos in TETROMINO_MAP[letter]:
		
		var bubble = BUBBLE.instantiate()
		bubble.modulate = color
		bubble.position = pos * PIXELS_PER_UNIT
		%Degree0.add_child(bubble)
		
		var pos90 = _rotate90(pos)
		var bubble90 = bubble.duplicate()
		bubble90.position = pos90 * PIXELS_PER_UNIT
		bubble90.visible = false
		%Degree90.add_child(bubble90)
		
		var pos180 = _rotate90(pos90)
		var bubble180 = bubble.duplicate()
		bubble180.position = pos180 * PIXELS_PER_UNIT
		bubble180.visible = false
		%Degree180.add_child(bubble180)
		
		var pos270 = _rotate90(pos180)
		var bubble270 = bubble.duplicate()
		bubble270.position = pos270 * PIXELS_PER_UNIT
		bubble270.visible = false
		%Degree270.add_child(bubble270)
		

func _process(delta: float) -> void:
	_time_till_move -= delta
	%FiniteStateMachine.process(delta)


func try_move(vec: Vector2, force: bool = false) -> bool:
	if (_time_till_move > 0 && not force) || is_position_blocked(vec):
		return false
	position += vec * PIXELS_PER_UNIT
	_time_till_move = _MOVE_COOLDOWN
	return true
	

func slam_time(vec: Vector2, force: bool = false) -> void:
	while !is_position_blocked(vec) && not force:
		position += vec * PIXELS_PER_UNIT
		break
	

func process_rotate(degrees: int) -> void:
	var previous_bubbles = get_bubbles()
	_current_rotation = (_current_rotation + degrees) % 360
	var current_bubbles = get_bubbles()
	
	if not wall_kick():
		_current_rotation = (_current_rotation + 360 - degrees) % 360
		return
	
	for child in previous_bubbles:
		if child is Bubble:
			child.visible = false
	for child in current_bubbles:
		if child is Bubble:
			child.visible = true
	

func _rotate90(pos: Vector2) -> Vector2:
	var pivot := Vector2(0.5, -0.5) if letter == 'I' || letter == 'O' else Vector2.ZERO
	var relative_pos = pos - pivot
	var rotated_pos = Vector2(relative_pos.y, -relative_pos.x)
	return rotated_pos + pivot
	
	
func wall_kick() -> bool:
	const kicks := [Vector2.UP, Vector2.RIGHT, Vector2.LEFT, Vector2.RIGHT]
	
	if !is_position_blocked(Vector2.ZERO):
		return true
	
	for kick in kicks:
		if try_move(kick):
			return true
	
	for first_kick in kicks:
		for second_kick in kicks:
			var double_kick = first_kick + second_kick
			if double_kick != Vector2.ZERO && try_move(double_kick):
				return true
	
	return false
	
	
func is_currently_blocked() -> bool:
	return is_position_blocked(Vector2.ZERO)
	

func is_left_blocked() -> bool:
	return is_position_blocked(Vector2.LEFT)


func is_right_blocked() -> bool:
	return is_position_blocked(Vector2.RIGHT)
	
	
func is_up_blocked() -> bool:
	return is_position_blocked(Vector2.UP)
	

func is_position_blocked(pos: Vector2) -> bool:
	for bubble in get_bubbles():
		if bubble.is_position_blocked(pos):
			return true
	return false


func get_bubbles() -> Array[Bubble]:
	var bubbles: Array[Bubble] = []
	var parent = get_node('Bubbles/Degree%d' % [_current_rotation])
	for child in parent.get_children():
		if child is Bubble:
			bubbles.append(child)
	return bubbles
	

func handle_placed() -> void:
	var bubbles = get_bubbles()
	for bubble in bubbles:
		bubble.get_parent().remove_child(bubble)
		bubble.on_place()
		bubble.animation_place(%GameClock.wait_time)
	Placed.emit(bubbles, position)
	queue_free()
	
