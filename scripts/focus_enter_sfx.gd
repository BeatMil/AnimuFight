extends Button

const BUTTON_FOCUS = preload("uid://bxpjgafdsk0v2")
const BUTTON_HIT = preload("uid://dptjjc511h1fs")

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer



func _ready() -> void:
	focus_entered.connect(focus_enter)
	pressed.connect(button_hit)


func focus_enter() -> void:
	audio_stream_player.stream = BUTTON_FOCUS
	audio_stream_player.play()


func button_hit() -> void:
	audio_stream_player.stream = BUTTON_HIT
	audio_stream_player.play()
