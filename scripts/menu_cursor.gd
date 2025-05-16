extends Node2D


var cursor_speed := 0.1
const BUTTON_FOCUS = preload("res://media/sfxs/button_focus.wav")
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func move_to(_position: Vector2) -> void:
	audio_stream_player.stream = BUTTON_FOCUS
	audio_stream_player.play()
	var tween = get_tree().create_tween()
	tween.set_pause_mode(tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "position", _position, cursor_speed).set_trans(Tween.TRANS_CUBIC)
