extends Node2D


#############################################################
## Config
#############################################################
@onready var current_zoom: Vector2 = $Camera2D.zoom


#############################################################
## Reference
#############################################################
@onready var camera_2d: Camera2D = $Camera2D


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
		camera_2d.offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
		# position = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
		shake_intensity = max(shake_intensity - shake_decay, 0)
	else:
		# Reset the position when done shaking
		camera_2d.offset = Vector2.ZERO
	

func start_screen_shake(intensity: float, duration: float):
	shake_intensity = intensity
	shake_duration = duration


func zoom(zoom_level: Vector2, duration: float = 0.1):
	var tween = get_tree().create_tween()
	tween.tween_property(camera_2d, "zoom", current_zoom+zoom_level, 0.1)
	tween.tween_interval(duration)
	tween.tween_property(camera_2d, "zoom", current_zoom, 0.1)


func set_screen_lock(left: int, right: int, top: int = -10000000, bottom: int = -10000000):
	camera_2d.limit_left = left
	camera_2d.limit_right = right
	camera_2d.limit_top = top
	camera_2d.limit_bottom = bottom


func set_zoom(zoom_level: Vector2):
	camera_2d.zoom = zoom_level
	current_zoom = zoom_level
