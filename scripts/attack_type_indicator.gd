extends Node2D


enum {
	PARRYABLE,
	DODGABLE,
	JF
}

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var type = PARRYABLE

func _ready() -> void:
	match type:
		PARRYABLE:
			animation_player.play("alert_parryable")
		DODGABLE:
			animation_player.play("alert_dodgable")
		JF:
			animation_player.play("jf")
		_:
			animation_player.play("alert_parryable")


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()
