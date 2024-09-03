extends "res://scripts/character_template.gd"


func _ready() -> void:
	$Timer.start()
	_lp()


func _on_timer_timeout() -> void:
	_lp()
