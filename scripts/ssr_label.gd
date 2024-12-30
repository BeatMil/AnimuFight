extends Node2D


var GACHA03 = preload("res://media/sfxs/gacha03.wav")
var label := "ssr"


func _ready() -> void:
	match label:
		"ssr":
			$LabelSetter.play("ssr")
		"a":
			$LabelSetter.play("a")
		"b":
			$LabelSetter.play("b")

	$AnimationPlayer.play("pop")
	$GPUParticles2D.emitting = true
	# _play_random_pitch_scale()


func _play_random_pitch_scale() -> void:
	var domm = randf_range(0.5, 1.5)
	$AudioStreamPlayer.set_stream(GACHA03)
	$AudioStreamPlayer.pitch_scale = domm
	$AudioStreamPlayer.play()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "pop":
		$AnimationPlayer.play("idle")
