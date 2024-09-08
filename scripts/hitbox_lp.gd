extends Node2D

#############################################################
## Node Ref
#############################################################
@onready var timer: Timer = $Timer
@onready var area_2d: Area2D = $Area2D


#############################################################
## Config
#############################################################
var is_hit_player: bool = false
var is_hit_enemy: bool = false
var time_left_before_queue_free: float = 1.0
var push_power: int = 20

#############################################################
## Built-in
#############################################################
func _ready() -> void:
	timer.wait_time = time_left_before_queue_free
	timer.start()
	if is_hit_player:
		_set_collision_hit_player()
	
	if is_hit_enemy:
		_set_collision_hit_enemy()


#############################################################
## Private Function
#############################################################
func _set_collision_hit_enemy() -> void:
	area_2d.collision_mask = 0b00000000000000000010


func _set_collision_hit_player() -> void:
	area_2d.collision_mask = 0b00000000000000000001


#############################################################
## Signals
#############################################################
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("hitted"):
		body.hitted(get_parent(), get_parent().is_face_right, push_power)



func _on_timer_timeout() -> void:
	queue_free()
