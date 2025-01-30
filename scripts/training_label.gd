extends Label

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func turn_green() -> void:
	animation_player.stop()
	animation_player.play("turn_green")
