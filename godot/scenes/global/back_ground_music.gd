extends Node2D

const zodiac_intro = preload ("res://music/zodiac_fullsong.mp3")
const zodiac_loop = preload ("res://music/zodiac_loop.mp3")

func _ready() -> void:
	%Music.play()
