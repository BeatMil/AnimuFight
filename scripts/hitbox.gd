extends Node2D

#############################################################
## Node Ref
#############################################################
@onready var active_frame_timer: Timer = $ActiveFrameTimer
@onready var area_2d: Area2D = $Area2D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var hit_noise = preload("res://media/sfxs/gc_punch.wav")


#############################################################
## Config
#############################################################
var is_hit_player: bool = false
var is_hit_enemy: bool = false
var active_frame: float = 1.0
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
var slow_mo_on_block = Vector2(0, 0)


#############################################################
## Built-in
#############################################################
func _ready() -> void:
	active_frame_timer.wait_time = active_frame
	active_frame_timer.start()
	if is_hit_player:
		_set_collision_hit_player()
	
	if is_hit_enemy:
		_set_collision_hit_enemy()

	if type == Enums.Attack.P_THROW:
		_set_collision_hit_enemy_all()

#############################################################
## Private Function
#############################################################
func _set_collision_hit_enemy() -> void:
	area_2d.collision_mask = 0b00000000000000010010


func _set_collision_hit_player() -> void:
	area_2d.collision_mask = 0b00000000000000000001


func _set_collision_no_hit() -> void:
	area_2d.collision_mask = 0b00000000000000000000


func _set_collision_hit_enemy_all() -> void:
	area_2d.collision_mask = 0b00000000000010010010


func _play_hit_random_pitch():
	audio_stream_player.stream = hit_noise
	audio_stream_player.pitch_scale = randf_range(0.8, 1.2)
	audio_stream_player.play()


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
			zoom_duration,
			slow_mo_on_block
			)
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
			zoom_duration,
			slow_mo_on_block
			)
		if body.state not in [
			body.States.BLOCK,
			body.States.PARRY,
			body.States.ARMOR,
			body.States.IFRAME,
			] and type not in [
			Enums.Attack.THROW_GROUND,
			Enums.Attack.THROW_FLOAT,
			Enums.Attack.P_THROW,
			Enums.Attack.P_AIR_THROW,
			Enums.Attack.P_WALL_THROW,
			Enums.Attack.P_GROUND_THROW,
			]:
			_play_hit_random_pitch()
		_on_timer_timeout()


func _on_timer_timeout() -> void:
	_set_collision_no_hit() # background_object shake twice if I use monitoring
	area_2d.visible = false


func _on_queue_free_timer_timeout() -> void:
	queue_free()
