extends Node2D
class_name Tetromino


signal Placed


@export_enum("I", "O", "T", "J", "L", "S", "Z") var letter: String = "T"
@export var hold_move_period: float = 0.5


const PIXELS_PER_UNIT = 32

const TETROMINO_COLORS = {
	"I": Color(0, 0.824, 0.914),
	"O": Color(0.902, 0.827, 0),
	"T": Color(0.765, 0, 0.91),
	"J": Color(0, 0.51, 0.914),
	"L": Color(0.89, 0.612, 0),
	"Z": Color(0.937, 0, 0),
	"S": Color(0.032, 0.658, 0.773),
}

const TETROMINO_MAP = {
	"I": [Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(2, 0)],
	"O": [Vector2(0, 0), Vector2(0, -1), Vector2(1, -1), Vector2(1, 0)],
	"T": [Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(0, 1)],
	"J": [Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(1, 1)],
	"L": [Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(-1, 1)],
	"Z": [Vector2(0, 0), Vector2(1, 0), Vector2(0, -1), Vector2(-1, -1)],
	"S": [Vector2(0, 0), Vector2(-1, 0), Vector2(0, -1), Vector2(1, -1)],
}

const BUBBLE := preload("res://scenes/game/tetromino/bubble.tscn")

var _current_rotation: int = 0


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
		

# Parameter vec is the direction to move.
# Parameter ceiling_stick tracks ceiling hits.		
func try_move(vec: Vector2, ceiling_stick: bool = false) -> bool:
	if is_position_blocked(vec):
		return false
	if ceiling_stick && !is_position_blocked(vec + Vector2(0, -2)):
		return false
	position += vec * PIXELS_PER_UNIT
	return true


func process_rotate(degrees: int) -> void:
	var enable_ceiling_stick := is_up_blocked()
	
	var previous_bubbles = get_bubbles()
	_current_rotation = (_current_rotation + degrees) % 360
	var current_bubbles = get_bubbles()
	
	if !_wall_kick(enable_ceiling_stick):
		_current_rotation = (_current_rotation + 360 - degrees) % 360
		return
	
	for child in previous_bubbles:
		if child is Bubble:
			child.visible = false
	for child in current_bubbles:
		if child is Bubble:
			child.visible = true
	

func _rotate90(pos: Vector2) -> Vector2:
	var pivot := Vector2(0.5, -0.5) if letter == 'I' || letter == 'O' else Vector2(0, 0)
	var relative_pos = pos - pivot
	var rotated_pos = Vector2(relative_pos.y, -relative_pos.x)
	return rotated_pos + pivot
	
	
func _wall_kick(ceiling_stick: bool) -> bool:
	const kicks := [Vector2(0, -1), Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1)]
	
	if try_move(Vector2(0, 0), ceiling_stick):
		return true
	
	for kick in kicks:
		if try_move(kick, ceiling_stick):
			return true
	
	for first_kick in kicks:
		for second_kick in kicks:
			var double_kick = first_kick + second_kick
			if double_kick != Vector2(0, 0) && try_move(double_kick, ceiling_stick):
				return true
	
	return false
	
	
func is_currently_blocked() -> bool:
	return is_position_blocked(Vector2(0, 0))
	

func is_left_blocked() -> bool:
	return is_position_blocked(Vector2(-1, 0))


func is_right_blocked() -> bool:
	return is_position_blocked(Vector2(1, 0))
	
	
func is_up_blocked() -> bool:
	return is_position_blocked(Vector2(0, -1))
	

func is_position_blocked(pos: Vector2) -> bool:
	for bubble in get_bubbles():
		if bubble.is_position_blocked(pos):
			return true
	return false


func get_bubbles(remove: bool = false) -> Array[Bubble]:
	var bubbles: Array[Bubble] = []
	var parent = get_node('Bubbles/Degree%d' % [_current_rotation])
	for child in parent.get_children():
		if child is Bubble:
			bubbles.append(child)
			if remove:
				parent.remove_child(child)
	return bubbles
	

func handle_placed() -> void:
	var bubbles = get_bubbles(true)
	for bubble in bubbles:
		bubble.on_place()
	Placed.emit(bubbles, position)
	
