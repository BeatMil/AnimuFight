extends "res://scripts/enemy.gd"

func _ready() -> void:
	super._ready()
	block_rate = 10
	DED_SPRITE = preload("res://media/sprites/enemy06/enemy06_down.png")


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


func _attack01() -> void:
	if state in [States.IDLE, States.BLOCK_STUNNED, States.BLOCK, States.ATTACK]:
		animation_player.play("attack01_1")
func attack01_info() -> void: # for animation_player
	var info = {
	"size": Hitbox_type.SMALL,
	"time": 0.3,
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
	"type": Enums.Attack.UNBLOCK,
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
		"attack01_1",
		"lp1_chain",
		"throw_float",
		"throw_ground",
		"df1_combo"
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
	if is_player_in_range_attack01:
		state = States.ATTACK
		_attack01()
	elif is_player_in_range_lp:
		state = States.ATTACK
		match randi_range(0, 3):
			0:
				_df1_combo()
			1:
				_df1_combo()
			2:
				_throw_ground()
			3:
				_throw_float()
