extends Node2D

var damage: int

func _ready() -> void:
	$Label.text = str(damage)
	$AnimationPlayer.play("out")


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()
