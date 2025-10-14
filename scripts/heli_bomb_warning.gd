extends Node2D


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D


var pitch_scale = 1


func _ready() -> void:
	audio_stream_player_2d.pitch_scale = pitch_scale
	animation_player.play("activate")
	audio_stream_player_2d.play()


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()
