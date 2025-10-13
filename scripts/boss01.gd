extends "res://scripts/enemy.gd"

signal next_phase

@onready var meteo_pos: Marker2D = $HitBoxPos/MeteoPos
@onready var detect_ground: Area2D = $DetectGround

@export var is_next_phase = false

var is_player_in_range_burn_knuckle = false


func _ready() -> void:
	super._ready()
	DED_SPRITE = preload("res://media/sprites/boss01/boss01_down.png")


func attack_timer_start() -> void:
	$AttackTimer.start()


func attack_timer_stop() -> void:
	$AttackTimer.stop()


#############################################################
## Attack Info
#############################################################
func _attack01() -> void:
	if state in [States.IDLE, States.BLOCK_STUNNED, States.BLOCK, States.ATTACK]:
		state = States.BLOCK
		match randi_range(0, 2):
			0:
				animation_player.play("meteo_crash")
			1:
				animation_player.play("burn_knuckle")
			2:
				animation_player.play("lp1")
func attack01_info() -> void: # for animation_player
	var info = {
	"size": Hitbox_type.MEDIUM,
	"time": 0.3,
	"push_power_ground": Vector2(800, -300),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(300, 0),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0.3,
	"hitstun_amount_ground": 0.6,
	"hitlag_amount_air": 0,
	"hitstun_amount_air": 0.5,
	"screenshake_amount": Vector2(20, 0.3),
	"damage": 3,
	"type": Enums.Attack.NORMAL,
	}
	dict_to_spawn_hitbox(info)


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
	"size": Hitbox_type.MEDIUM,
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
	"damage": 2,
	"type": Enums.Attack.NORMAL,
	"zoom": Vector2(0.5, 0.5),
	"zoom_duration": 0.7,
	"slow_mo_on_block": Vector2(0.5, 0.2),
	}
	dict_to_spawn_hitbox(info)


func tatsu_2nd_info() -> void: # for animation_player
	var info = {
	"size": Hitbox_type.MEDIUM,
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
	"damage": 2,
	"type": Enums.Attack.NORMAL,
	# "zoom": Vector2(0.5, 0.5),
	# "zoom_duration": 1,
	# "slow_mo_on_block": Vector2(0.5, 0.2),
	}
	dict_to_spawn_hitbox(info)


func tatsu_end_info() -> void: # for animation_player
	var info = {
	"size": Hitbox_type.MEDIUM,
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
	"damage": 3,
	"type": Enums.Attack.NORMAL,
	}
	dict_to_spawn_hitbox(info)


func burn_knuckle() -> void:
	if state in [States.IDLE, States.ATTACK]:
		state = States.ATTACK
		animation_player.play("burn_knuckle")
func burn_knuckle_info() -> void: # for animation_player
	var info = {
	"size": Hitbox_type.MEDIUM,
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
	"damage": 2,
	"type": Enums.Attack.NORMAL,
	}
	dict_to_spawn_hitbox(info)


func meteo_crash() -> void:
	if state in [States.IDLE, States.ATTACK]:
		state = States.ATTACK
		animation_player.play("meteo_crash")
func meteo_crash_info() -> void: # for animation_player
	var info = {
	"size": Hitbox_type.METEO,
	"time": 1,
	"push_power_ground": Vector2(1000, -200),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(1000, -200),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0.3,
	"hitstun_amount_ground": 0.5,
	"hitlag_amount_air": 0.3,
	"hitstun_amount_air": 0.5,
	"screenshake_amount": Vector2(0, 0),
	"damage": 6,
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


func _on_lp_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_in_range_lp = true
		# _on_attack_timer_timeout()
	elif body.is_in_group("enemy") \
		and target.position.x > position.x:
		is_enemy_in_range_lp = true


func _on_lp_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_in_range_lp = false
	elif body.is_in_group("enemy"):
		is_enemy_in_range_lp = false


func _on_burn_knuckle_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_in_range_burn_knuckle = true
		# _on_attack_timer_timeout()


func _on_burn_knuckle_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_in_range_burn_knuckle = false


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


func _on_attack_timer_timeout() -> void:
	if state != States.IDLE:
		return
	if randi_range(0, 1) == 0:
		return

	AttackQueue.queueing_to_attack(self)


func do_attack() -> void:
	if is_player_in_range_burn_knuckle or is_player_in_range_lp:
		state = States.ATTACK
		_attack01()


func _on_detect_ground_body_entered(_body: Node2D) -> void:
	if animation_player.current_animation == "meteo_crash" \
		and state == States.PUNISHABLE:
		set_collision_normal()
		ObjectPooling.spawn_ground_spark(global_position, false)
		CameraManager.start_screen_shake(50, 0.3)


func boss_next_phase() -> void:
	if is_next_phase:
		is_controllable = false
		is_notarget = true
		attack_timer_stop()
		collision_layer= 0b00000000000000000000
		await get_tree().create_timer(0.1).timeout
		animation_player.play("whistle")
		await get_tree().create_timer(2).timeout
		animation_player.play("jump_away")
		await get_tree().create_timer(1).timeout
		emit_signal("next_phase")
		queue_free()
	else:
		spawn_ded_copy()
		queue_free()
