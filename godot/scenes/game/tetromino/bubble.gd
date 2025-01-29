extends Node2D
class_name Bubble


signal BubblePopped


const DEFAULT_TICK = .5
const BUBBLE_POP_DURATION = 0.5
const NEXT_BUBBLE_WAIT = 0.05
@export var has_powerup := false

var row 
var column
var score = 1

func get_powerup() -> PowerUp:
	for child in get_children():
		if child is PowerUp:
			return child
	return null

func pop(ordinal: int) -> void:
	await get_tree().create_timer(ordinal * NEXT_BUBBLE_WAIT).timeout 
	animation_pop()
	make_pop_sound(ordinal)
	await %BubbleAnimationPlayer.animation_finished
	BubblePopped.emit()
	queue_free()
	
func change_position_after_pop(pos: Vector2) -> Signal:
	var tween = create_tween()
	tween.tween_property(self, "position", pos, 0.75) \
		.set_trans(Tween.TRANS_BACK) \
		.set_ease(Tween.EASE_IN_OUT)
	animation_place(0.5) # todo fix
	return tween.finished

func receive_powerup(powerup: PowerUp) -> void:
	add_child(powerup)
	modulate = Color(1, 1, 1)
	if powerup.type == "mult":
		%Bubble.frame = 11
	else:
		%Bubble.frame = 6
	
func animation_place(game_tick_length:float) -> void:
	%BubbleAnimationPlayer.speed_scale = 2 * (DEFAULT_TICK/game_tick_length)
	%BubbleAnimationPlayer.play("Place")
	await %BubbleAnimationPlayer.animation_finished
	%BubbleAnimationPlayer.speed_scale = .1
	%BubbleAnimationPlayer.queue("idle")

func animation_pop() -> void:
	%BubbleAnimationPlayer.speed_scale = 1 / BUBBLE_POP_DURATION
	if get_powerup() != null:
		if get_powerup().type == "mult":
			%BubbleAnimationPlayer.play("popMult")
		else:
			%BubbleAnimationPlayer.play("popFlat")
	else:
		%BubbleAnimationPlayer.play("pop")
	
func animation_idle() -> void:
	%BubbleAnimationPlayer.speed_scale = .1
	%BubbleAnimationPlayer.queue("idle")
	
func animation_coyote_input(game_tick_length:float) -> void:
	if $BubbleAnimationPlayer.current_animation != "coyote": 
		%BubbleAnimationPlayer.speed_scale = 4 * (DEFAULT_TICK/game_tick_length)
		%BubbleAnimationPlayer.play("coyote")
	
func make_pop_sound(ordinal: int) -> void:
	var pitch_intensity = float(ordinal) * 0.06 + 1.0
	%PopSound.pitch_scale = pitch_intensity
	%PopSound.play()
