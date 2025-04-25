extends "res://scripts/enemy.gd"

@onready var meteo_pos: Marker2D = $HitBoxPos/MeteoPos


#############################################################
## Attack Info
#############################################################
func _lp() -> void:
	if state in [States.IDLE, States.ATTACK]:
		state = States.ATTACK
		animation_player.play("lp1")
func _lp_chain() -> void:
	if state in [States.IDLE, States.ATTACK]:
		state = States.ATTACK
		animation_player.play("lp1_chain")
func lp_info() -> void: # for animation_player
	var info = {
	"size": Hitbox_size.MEDIUM,
	"time": 0.1,
	"push_power_ground": Vector2(10, 0),
	"push_type_ground": Enums.Push_types.NORMAL,
	"push_power_air": Vector2(10, -150),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0,
	"hitstun_amount_ground": 0.5,
	"hitlag_amount_air": 0,
	"hitstun_amount_air": 0.5,
	"screenshake_amount": Vector2(0, 0),
	"damage": 1,
	"type": Enums.Attack.NORMAL,
	"zoom": Vector2(0.5, 0.5),
	"zoom_duration": 0.7,
	"slow_mo_on_block": Vector2(0.5, 0.2),
	}
	dict_to_spawn_hitbox(info)


func tatsu_2nd_info() -> void: # for animation_player
	var info = {
	"size": Hitbox_size.MEDIUM,
	"time": 0.1,
	"push_power_ground": Vector2(10, 0),
	"push_type_ground": Enums.Push_types.NORMAL,
	"push_power_air": Vector2(10, -150),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0,
	"hitstun_amount_ground": 0.5,
	"hitlag_amount_air": 0,
	"hitstun_amount_air": 0.5,
	"screenshake_amount": Vector2(0, 0),
	"damage": 1,
	"type": Enums.Attack.NORMAL,
	"zoom": Vector2(0.5, 0.5),
	# "zoom_duration": 1,
	# "slow_mo_on_block": Vector2(0.5, 0.2),
	}
	dict_to_spawn_hitbox(info)


func tatsu_end_info() -> void: # for animation_player
	var info = {
	"size": Hitbox_size.MEDIUM,
	"time": 0.1,
	"push_power_ground": Vector2(1000, -100),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(500, -150),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0.2,
	"hitstun_amount_ground": 0.5,
	"hitlag_amount_air": 0.2,
	"hitstun_amount_air": 0.5,
	"screenshake_amount": Vector2(50, 0.1),
	"damage": 1,
	"type": Enums.Attack.NORMAL,
	}
	dict_to_spawn_hitbox(info)


func burn_knuckle() -> void:
	if state in [States.IDLE, States.ATTACK]:
		state = States.ATTACK
		animation_player.play("burn_knuckle")
func burn_knuckle_info() -> void: # for animation_player
	var info = {
	"size": Hitbox_size.MEDIUM,
	"time": 0.1,
	"push_power_ground": Vector2(10, 0),
	"push_type_ground": Enums.Push_types.NORMAL,
	"push_power_air": Vector2(10, -150),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0,
	"hitstun_amount_ground": 0.5,
	"hitlag_amount_air": 0,
	"hitstun_amount_air": 0.5,
	"screenshake_amount": Vector2(0, 0),
	"damage": 1,
	"type": Enums.Attack.NORMAL,
	}
	dict_to_spawn_hitbox(info)


func meteo_crash() -> void:
	if state in [States.IDLE, States.ATTACK]:
		state = States.ATTACK
		animation_player.play("meteo_crash")
func meteo_crash_info() -> void: # for animation_player
	var info = {
	"size": Hitbox_size.METEO,
	"time": 5,
	"push_power_ground": Vector2(1000, -200),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(1000, -200),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0.3,
	"hitstun_amount_ground": 0.5,
	"hitlag_amount_air": 0.3,
	"hitstun_amount_air": 0.5,
	"screenshake_amount": Vector2(0, 0),
	"damage": 4,
	"type": Enums.Attack.UNBLOCK,
	"pos": meteo_pos.position,
	}
	dict_to_spawn_hitbox(info)


#############################################################
## Signals
#############################################################
func _on_timer_timeout() -> void:
	if hp_bar.get_hp() > 0:
		_lp()


func _on_lp_range_r_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_in_range_lp = true
		_on_attack_timer_timeout()
	elif body.is_in_group("enemy") \
		and target.position.x > position.x:
		is_enemy_in_range_lp = true


func _on_lp_range_l_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_in_range_lp = true
		_on_attack_timer_timeout()
	elif body.is_in_group("enemy") \
		and target.position.x < position.x:
		is_enemy_in_range_lp = true


func _on_lp_range_r_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_in_range_lp = false
	elif body.is_in_group("enemy"):
		is_enemy_in_range_lp = false


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	# if anim_name in ["lp1", "attack01_1", "hitted", "down"]:
	if anim_name in [
		"lp1",
		"attack01_1",
		"lp1_chain",
		"burn_knuckle",
		"meteo_crash",
		]:
		animation_player.play("idle")
		state = States.IDLE
	if anim_name in ["ded"]:
		queue_free()


func _on_attack_timer_timeout() -> void:
	if state != States.IDLE:
		return
	if randi_range(0, 0) == 1:
		return
	if not AttackQueue.can_attack:
		return
	# Reset attack queue
	AttackQueue.start_queue_timer()

	# if is_player_in_range_attack01:
	# 	_attack01()
	if is_player_in_range_lp:
		meteo_crash()
		# burn_knuckle()
		# _lp()
