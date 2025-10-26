extends Node


var player: CharacterBody2D


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_8 and event.is_pressed():
		print("hp up!")
		player.hp_bar.hp_up(1)
	elif event is InputEventKey and event.keycode == KEY_9 and event.is_pressed():
		print("hp down!")
		player.hp_bar.hp_down(1)
	pass
