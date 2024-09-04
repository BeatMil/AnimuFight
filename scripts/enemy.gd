extends "res://scripts/base_character.gd"


func _ready() -> void:
	$Timer.start()
	_lp()


func _on_timer_timeout() -> void:
	_lp()
