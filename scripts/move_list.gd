extends Control

signal selected

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var background: Panel = $Background


var idle_color = Color(0.655, 0.781, 0.996, 0.094)
var selected_color = Color(0.565, 0.975, 0.923, 0.094)


func play_sfx() -> void:
	audio_stream_player.pitch_scale = randf_range(0.5, 1.5)
	audio_stream_player.play()

func _ready() -> void:
	_on_focus_exited()


func _on_focus_entered() -> void:
	emit_signal("selected")
	background.get("theme_override_styles/panel").bg_color = selected_color
	play_sfx()


func _on_focus_exited() -> void:
	background.get("theme_override_styles/panel").bg_color = idle_color
