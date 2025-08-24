extends Node2D


@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var particle_pos: Marker2D = $Particle_pos
@onready var animation_player: AnimationPlayer = $AnimationPlayer
const LIGHT_PARTICLE = preload("res://nodes/hitsparks/light_particle.tscn")
const GLASS_CLASH = preload("res://media/sfxs/GlassClash.wav")


func play_random_pitch(hit_noise):
	audio_stream_player.stream = hit_noise
	audio_stream_player.pitch_scale = randf_range(0.8, 1.2)
	audio_stream_player.play()


func _on_area_2d_body_entered(_body: Node2D) -> void:
	animation_player.play("break")
	var part = LIGHT_PARTICLE.instantiate()
	part.position = particle_pos.position
	add_child(part)
	play_random_pitch(GLASS_CLASH)
