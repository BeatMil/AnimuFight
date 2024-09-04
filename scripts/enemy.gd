extends "res://scripts/base_character.gd"

@export var target: CharacterBody2D


#############################################################
## Config
#############################################################
# var is_face_right:bool = true
var SPEED:int = 100


func _physics_process(_delta: float) -> void:
	is_face_right = not sprite_2d.flip_h
	_z_index_equal_to_y()
	_move(_delta)
	_facing()


func _ready() -> void:
	# $Timer.start()
	_lp()


#############################################################
## Private Function
#############################################################
func _move( delta):
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
