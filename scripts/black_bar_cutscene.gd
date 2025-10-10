extends Node2D


@onready var animation_player: AnimationPlayer = $AnimationPlayer


func enable() -> void:
	animation_player.play("action")


func disable() -> void:
	animation_player.play("unaction")
