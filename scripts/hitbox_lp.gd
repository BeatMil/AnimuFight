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
var push_power_ground: Vector2 = Vector2(20, 0)
var push_type_ground: Enums.Push_types = Enums.Push_types.NORMAL
var push_power_air: Vector2 = Vector2(20, 0)
var push_type_air: Enums.Push_types = Enums.Push_types.NORMAL
var hitlag_amount_ground: float = 0
var hitstun_amount_ground: float = 0
var hitlag_amount_air: float = 0
var hitstun_amount_air: float = 0
var screenshake_amount: Vector2 = Vector2(0, 0)
var damage: int = 0
var type = Enums.Attack.NORMAL
var zoom = Vector2(0.8, 0.8)
var zoom_duration = 0.1


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
		if body.is_on_floor():
			body.hitted(get_parent(),
			get_parent().is_face_right,
			push_power_ground,
			push_type_ground,
			hitlag_amount_ground,
			hitstun_amount_ground,
			screenshake_amount,
			damage,
			type,
			zoom,
			zoom_duration)
		else:
			body.hitted(get_parent(),
			get_parent().is_face_right,
			push_power_air,
			push_type_air,
			hitlag_amount_air,
			hitstun_amount_air,
			screenshake_amount,
			damage,
			type,
			zoom,
			zoom_duration)


func _on_timer_timeout() -> void:
	queue_free()
