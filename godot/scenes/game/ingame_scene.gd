extends Node2D

@onready var fade_overlay = %FadeOverlay
@onready var pause_overlay = %PauseOverlay

func _ready() -> void:
	%IntroMusic.play()
	%IntroMusic.connect("finished", _on_intro_finished)
	fade_overlay.visible = true
	
	if SaveGame.has_save():
		SaveGame.load_game(get_tree())
	
	pause_overlay.game_exited.connect(_save_game)
	
	%BackgroundAnimations.play("game_start")
	%BackgroundAnimations.queue("background_idle")
	
	
func _input(event) -> void:
	if event.is_action_pressed("pause") and not pause_overlay.visible:
		get_viewport().set_input_as_handled()
		get_tree().paused = true
		pause_overlay.grab_button_focus()
		pause_overlay.visible = true
		
func _save_game() -> void:
	SaveGame.save_game(get_tree())

func _on_intro_finished():
	%LoopMusic.play()


func _on_play_area_popped_bubbles() -> void:
	pass # Replace with function body.
