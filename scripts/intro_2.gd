extends Node2D


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "a":
		SceneTransition.change_scene("res://scenes/stage01.tscn")
	pass # Replace with function body.
