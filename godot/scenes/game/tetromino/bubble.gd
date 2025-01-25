extends Node2D
class_name Bubble

const DEFAULT_TICK = .5

# Score representing the basic number of points for popping a single bubble
var bubble_score = 10
var row

func is_position_blocked(pos: Vector2) -> bool:
	var area = get_node("DetectionRows/Row[%d]/Area[%d]" % [pos.y, pos.x])
	var blocked = area is not Area2D || area.has_overlapping_areas()
	return blocked


func on_place() -> void:
	var area: Area2D = get_node("DetectionRows/Row[0]/Area[0]")
	area.monitorable = true
	remove_child(%SlamCast)

	
func distance_to_slam() -> float:
	assert(%SlamCast.is_colliding())
	return global_position.distance_to(%SlamCast.get_collision_point())
	
func animation_place(game_tick_length:float) -> void:
	%BubbleAnimationPlayer.speed_scale = 2 * (DEFAULT_TICK/game_tick_length)
	%BubbleAnimationPlayer.play("Place")
	await %BubbleAnimationPlayer.animation_finished
	%BubbleAnimationPlayer.speed_scale = .1
	%BubbleAnimationPlayer.queue("idle")

func animation_pop(game_tick_length:float) -> void:
	%BubbleAnimationPlayer.speed_scale = 2 * (DEFAULT_TICK/game_tick_length)
	%BubbleAnimationPlayer.play("pop")
	
func animation_idle() -> void:
	%BubbleAnimationPlayer.speed_scale = .1
	%BubbleAnimationPlayer.queue("idle")
	
func animation_coyote_input(game_tick_length:float) -> void:
	if $BubbleAnimationPlayer.current_animation != "coyote": 
		%BubbleAnimationPlayer.speed_scale = 4 * (DEFAULT_TICK/game_tick_length)
		%BubbleAnimationPlayer.play("coyote")
		

func set_row(bubble_row:int) -> void:
	row = bubble_row
	

func get_row() -> int:
	return row
