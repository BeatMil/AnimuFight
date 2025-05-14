extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_area_2d_area_entered(area: Area2D) -> void:
	print("area: ", area.name, area.get_groups())
	if area.is_in_group("hitbox"):
		animation_player.stop()
		animation_player.play("shake")
