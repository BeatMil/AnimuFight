extends "res://scripts/enemy.gd"


@onready var keep_player_away_box: StaticBody2D = $KeepPlayerAwayBox


func _ready() -> void:
	super._ready()
	block_rate = 5
	DED_SPRITE = preload("uid://73v1gc7dgtjt")


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if state in [States.IDLE, States.BLOCK]:
		keep_player_away_box.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		keep_player_away_box.process_mode = Node.PROCESS_MODE_DISABLED


func spawn_boom_spark() -> void:
	ObjectPooling.spawn_boom_spark(global_position, true)


#############################################################
## Attack Info
#############################################################
func _lp() -> void:
	if state in [States.IDLE, States.ATTACK]:
		animation_player.play("lp1")
func _lp_chain() -> void:
	if state in [States.IDLE, States.ATTACK]:
		state = States.ATTACK
		animation_player.play("lp1_chain")
func lp_info() -> void: # for animation_player
	var info = {
	"size": Hitbox_type.MEDIUM,
	"time": 0.1,
	"push_power_ground": Vector2(500, 0),
	"push_type_ground": Enums.Push_types.NORMAL,
	"push_power_air": Vector2(100, -150),
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


func _boom() -> void:
	if state in [States.IDLE, States.BLOCK_STUNNED, States.BLOCK, States.ATTACK]:
		animation_player.play("boom")
func boom_info() -> void: # for animation_player
	var info = {
	"size": Hitbox_type.BOOM,
	"time": 100,
	"push_power_ground": Vector2(800, -300),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(800, -300),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0.2,
	"hitstun_amount_ground": 0.8,
	"hitlag_amount_air": 0,
	"hitstun_amount_air": 0.05,
	"screenshake_amount": Vector2(10, 0.1),
	"damage": 4,
	"type": Enums.Attack.PROJECTILE,
	"pos": Vector2(50, 0),
	}
	dict_to_spawn_hitbox(info)


func _throw_ground() -> void:
	if state in [States.IDLE, States.BLOCK_STUNNED, States.BLOCK, States.ATTACK]:
		state = States.BLOCK
		animation_player.play("throw_ground")
		ObjectPooling.spawn_throw_spark_ground(position)
func throw_ground_info() -> void: # for animation_player
	var info = {
	"size": Hitbox_type.THROW,
	"time": 0.1,
	"push_power_ground": Vector2(500, 0),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(100, -150),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0,
	"hitstun_amount_ground": 0.5,
	"hitlag_amount_air": 0,
	"hitstun_amount_air": 0.5,
	"screenshake_amount": Vector2(0, 0),
	"damage": 2,
	"type": Enums.Attack.THROW_GROUND,
	# "pos": $HitBoxPos/TowlPos.position,
	}
	dict_to_spawn_hitbox(info)


func _throw_float() -> void:
	if state in [States.IDLE, States.BLOCK_STUNNED, States.BLOCK, States.ATTACK]:
		state = States.BLOCK
		animation_player.play("throw_float")
		ObjectPooling.spawn_throw_spark_float(position)
func throw_float_info() -> void: # for animation_player
	var info = {
	"size": Hitbox_type.THROW,
	"time": 0.1,
	"push_power_ground": Vector2(500, 0),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(100, -150),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0,
	"hitstun_amount_ground": 0.5,
	"hitlag_amount_air": 0,
	"hitstun_amount_air": 0.5,
	"screenshake_amount": Vector2(0, 0),
	"damage": 2,
	"type": Enums.Attack.THROW_FLOAT,
	# "pos": $HitBoxPos/TowlPos.position,
	}
	dict_to_spawn_hitbox(info)


func _df1_combo() -> void:
	if state in [States.IDLE, States.BLOCK_STUNNED, States.BLOCK, States.ATTACK]:
		state = States.BLOCK
		animation_player.play("df1_combo")
func df1_info() -> void: # for animation_player
	var info = {
	"size": Hitbox_type.SMALL,
	"time": 0.1,
	"push_power_ground": Vector2(500, 0),
	"push_type_ground": Enums.Push_types.NORMAL,
	"push_power_air": Vector2(100, -150),
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
func df1_2nd_info() -> void: # for animation_player
	var info = {
	"size": Hitbox_type.SMALL,
	"time": 0.1,
	"push_power_ground": Vector2(500, -100),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(100, -150),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0.1,
	"hitstun_amount_ground": 0.5,
	"hitlag_amount_air": 0,
	"hitstun_amount_air": 0.5,
	"screenshake_amount": Vector2(0, 0),
	"damage": 4,
	"type": Enums.Attack.NORMAL,
	}
	dict_to_spawn_hitbox(info)


func play_blockstunned() -> void:
	if animation_player.current_animation == "blockstunned":
		animation_player.play("blockstunned_2")
	else:
		animation_player.play("blockstunned")


func _move_range(delta) -> void:
	if state in [States.IDLE]:
		is_wall_bounced = false
		is_wall_splat =  false
		if not is_player_in_range_attack01 and not is_enemy_in_range_lp:
			_move(delta)
		else:
			# lerp when finding player
			_lerp_velocity_x()
			animation_player.play("idle")
			# block_count = 0


#############################################################
## Signals
#############################################################
func _on_timer_timeout() -> void:
	if hp_bar.get_hp() > 0:
		_lp()


func _on_lp_range_r_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		sprite_2d.flip_h = false
		is_player_in_range_lp = true
		_on_attack_timer_timeout()
		attack_timer.start()
	elif body.is_in_group("enemy") \
		and target.position.x > position.x:
		is_enemy_in_range_lp = true


func _on_lp_range_l_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		sprite_2d.flip_h = true
		is_player_in_range_lp = true
		_on_attack_timer_timeout()
		attack_timer.start()
	elif body.is_in_group("enemy") \
		and target.position.x < position.x:
		is_enemy_in_range_lp = true


func _on_attack_01_range_r_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		sprite_2d.flip_h = false
		is_player_in_range_attack01 = true
		_on_attack_timer_timeout()
		attack_timer.start()

func _on_attack_01_range_l_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		sprite_2d.flip_h = true
		is_player_in_range_attack01 = true
		_on_attack_timer_timeout()
		attack_timer.start()


func _on_attack_range_01r_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_in_range_attack01 = false
		attack_timer.stop()


func _on_lp_range_r_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_in_range_lp = false
		attack_timer.stop()
	elif body.is_in_group("enemy"):
		is_enemy_in_range_lp = false


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "execute":
		animation_player.play("idle")
		hp_bar.hp_up(5)
	if anim_name in [
		"lp1",
		"lp1_chain",
		"throw_float",
		"throw_ground",
		"df1_combo",
		"boom",
		]:
		animation_player.play("idle")
		state = States.IDLE
	if anim_name in ["ded"]:
		queue_free()


func _on_attack_timer_timeout() -> void:
	if state != States.IDLE:
		return
	if randi_range(0, 1) == 0:
		return

	AttackQueue.queueing_to_attack(self)


func do_attack() -> void:
	# state = States.ATTACK
	if is_player_in_range_lp:
		match randi_range(0, 1):
			0:
				_throw_ground()
			1:
				_throw_float()
	elif is_player_in_range_attack01:
		_boom()
