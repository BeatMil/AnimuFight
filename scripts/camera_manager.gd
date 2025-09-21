extends Node2D


enum {
	PLAYER,
	TRANS,
	OTHER,
}


#############################################################
## Config
#############################################################
@export var player_cam: Camera2D
@export var transition_cam: Camera2D
@export var other_cam: Camera2D
@export var player: CharacterBody2D

var current_cam: Camera2D
var is_following_player = true

@onready var current_zoom: Vector2 = Vector2(1, 1)
@onready var current_lock: Dictionary = {
	"left": -10000000,
	"right": 10000000,
	"top": -10000000,
	"bottom": 10000000,
}

var no_screen_lock: = {
	"left": -10000000,
	"right": 10000000,
	"top": -10000000,
	"bottom": 10000000,
}


# Variables for shaking
var shake_intensity = 0
# var shake_decay = 0.05
var shake_decay = 0.0001
var shake_duration = 0


func _ready() -> void:
	current_cam = player_cam
	player = get_tree().current_scene.get_node("Player")


func make_current(enum_cam: int):
	match enum_cam:
		PLAYER:
			player_cam.make_current()
			current_cam = player_cam
		TRANS:
			transition_cam.make_current()
			current_cam = transition_cam
		OTHER:
			other_cam.make_current()
			current_cam = other_cam


func _process(delta: float) -> void:
	## ChatGPT baby!! XD
	if shake_duration > 0:
		shake_duration -= delta
		# Randomize the offset for the screen shake effect
		current_cam.offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
		# position = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
		shake_intensity = max(shake_intensity - shake_decay, 0)
	else:
		# Reset the position when done shaking
		current_cam.offset = Vector2.ZERO

	if player and is_following_player:
		player_cam.global_position = player.global_position
	

func start_screen_shake(intensity: float, duration: float):
	shake_intensity = intensity
	shake_duration = duration


func zoom(zoom_level: Vector2, duration: float = 0.1):
	var tween = get_tree().create_tween()
	tween.tween_property(current_cam, "zoom", current_zoom+zoom_level, 0.1)
	tween.tween_interval(duration)
	tween.tween_property(current_cam, "zoom", current_zoom, 0.1)


func zoom_zoom(zoom_level: Vector2, duration: float = 0.1):
	# disable_screen_lock()
	var tween = get_tree().create_tween()
	tween.tween_property(current_cam, "zoom", current_zoom+zoom_level, 0.3)
	tween.tween_interval(duration)
	tween.tween_property(current_cam, "zoom", current_zoom, 0.25)


func zoom_permanent(zoom_level: Vector2):
	var tween = get_tree().create_tween()
	tween.tween_property(current_cam, "zoom", current_zoom+zoom_level, 0.3)
	current_zoom = current_zoom+zoom_level


func set_screen_lock(
	left: int,
	right: int,
	top: int = -10000000,
	bottom: int = -10000000,
	camera: Camera2D = current_cam
	):
	camera.limit_left = left
	camera.limit_right = right
	camera.limit_top = top
	camera.limit_bottom = bottom
	current_lock["left"] = left
	current_lock["right"] = right
	current_lock["top"] = top
	current_lock["bottom"] = bottom


func apply_current_lock(camera: Camera2D = current_cam):
	camera.limit_left = current_lock["left"]
	camera.limit_right = current_lock["right"]
	camera.limit_top = current_lock["top"]
	camera.limit_bottom = current_lock["bottom"]


func disable_screen_lock(camera: Camera2D = current_cam) -> void:
	camera.limit_left = no_screen_lock["left"]
	camera.limit_right = no_screen_lock["right"]
	camera.limit_top = no_screen_lock["top"]
	camera.limit_bottom = no_screen_lock["bottom"]


func set_zoom(zoom_level: Vector2):
	var tween = get_tree().create_tween()
	tween.tween_property(current_cam, "zoom", zoom_level, 0.3)
	current_zoom = zoom_level


func pos_limit_to_player(left, right, top, bottom):
	transition_cam.position = player_cam.get_screen_center_position()
	make_current(1)
	set_screen_lock(left, right, top, bottom)
	var tween = get_tree().create_tween()
	tween.tween_property(transition_cam, "position", player.position, 0.2).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(0.2)
	tween.tween_callback(make_current.bind(0))
	tween.tween_callback(apply_current_lock)


func pos_lock(_pos: Vector2):
	is_following_player = false
	current_cam.position = _pos


func pos_lock_to_player():
	is_following_player = true
