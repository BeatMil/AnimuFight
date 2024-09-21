extends Node2D


# Variables for shaking
var shake_intensity = 0
# var shake_decay = 0.05
var shake_decay = 0.0001
var shake_duration = 0


func _process(delta: float) -> void:
	## ChatGPT baby!! XD
	if shake_duration > 0:
		shake_duration -= delta
		# Randomize the offset for the screen shake effect
		position = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
		shake_intensity = max(shake_intensity - shake_decay, 0)
	else:
		# Reset the position when done shaking
		position = Vector2.ZERO
	

func start_screen_shake(intensity: float, duration: float):
	shake_intensity = intensity
	shake_duration = duration
