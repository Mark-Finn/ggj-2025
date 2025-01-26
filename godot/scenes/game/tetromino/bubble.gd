extends Node2D
class_name Bubble


signal BubblePopped


const DEFAULT_TICK = .5
const BUBBLE_POP_DURATION = 0.5
const NEXT_BUBBLE_WAIT = 0.05


var row 
var column
var score = 10
	

func pop(ordinal: int) -> void:
	make_pop_sound()
	await get_tree().create_timer(ordinal * NEXT_BUBBLE_WAIT).timeout 
	animation_pop()
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

	
func animation_place(game_tick_length:float) -> void:
	%BubbleAnimationPlayer.speed_scale = 2 * (DEFAULT_TICK/game_tick_length)
	%BubbleAnimationPlayer.play("Place")
	await %BubbleAnimationPlayer.animation_finished
	%BubbleAnimationPlayer.speed_scale = .1
	%BubbleAnimationPlayer.queue("idle")

func animation_pop() -> void:
	%BubbleAnimationPlayer.speed_scale = 1 / BUBBLE_POP_DURATION
	%BubbleAnimationPlayer.play("pop")
	
func animation_idle() -> void:
	%BubbleAnimationPlayer.speed_scale = .1
	%BubbleAnimationPlayer.queue("idle")
	
func animation_coyote_input(game_tick_length:float) -> void:
	if $BubbleAnimationPlayer.current_animation != "coyote": 
		%BubbleAnimationPlayer.speed_scale = 4 * (DEFAULT_TICK/game_tick_length)
		%BubbleAnimationPlayer.play("coyote")
	
func make_pop_sound() -> void:
	%PopSound.play()
