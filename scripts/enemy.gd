extends "res://scripts/base_character.gd"

@export var target: CharacterBody2D


enum {
	FOLLOW,
	}


#############################################################
## Config
#############################################################
# var is_face_right:bool = true
var SPEED: int = 100
var is_player_in_range: bool = false


func _physics_process(_delta: float) -> void:
	is_face_right = not sprite_2d.flip_h
	_z_index_equal_to_y()
	_move(_delta)
	_facing()
	if is_player_in_range:
		_lp()


func _ready() -> void:
	pass
	# $Timer.start()
	# _lp()


#############################################################
## Private Function
#############################################################
func _move( delta):
	if state == States.IDLE:
		var direction = (target.position - global_position).normalized() 
		var desired_velocity =  direction * SPEED
		var steering = (desired_velocity - velocity) * delta * 2.5
		velocity += steering
		move_and_slide()


func _facing() -> void:
	if velocity.x > 0 :
		sprite_2d.flip_h = false
	else:
		sprite_2d.flip_h = true


func _on_timer_timeout() -> void:
	if hp_bar.get_hp() > 0:
		_lp()


#############################################################
## Signals
#############################################################
func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_in_range = true


func _on_attack_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_in_range = false
