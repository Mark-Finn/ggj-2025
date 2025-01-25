extends Node2D
class_name Bubble




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
	
func animation_place() -> void:
	%BubbleAnimationPlayer.speed_scale = 0.3
	%BubbleAnimationPlayer.play("Place")

func animation_idle() -> void:
	%BubbleAnimationPlayer.speed_scale = 0.1
	%BubbleAnimationPlayer.queue("idle")
	
func animation_coyote_input() -> void:
	%BubbleAnimationPlayer.speed_scale = 1.0
	%BubbleAnimationPlayer.play("coyote")
