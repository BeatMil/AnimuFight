extends "res://scripts/enemy.gd"


# const DED_SPRITE = preload("res://media/sprites/char2/enemy01_down.png")
@onready var keep_player_away_box: StaticBody2D = $KeepPlayerAwayBox
signal mango_boss_down


func _ready() -> void:
	super._ready()
	block_rate = 10
	DED_SPRITE = preload("res://media/sprites/mango_boss/mango_boss_down.png")


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if state in [States.IDLE, States.BLOCK]:
		keep_player_away_box.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		keep_player_away_box.process_mode = Node.PROCESS_MODE_DISABLED



#############################################################
## Attack Info
#############################################################
func _lp() -> void:
	if state in [States.IDLE, States.ATTACK]:
		animation_player.play("lp")
func _lp_chain() -> void:
	if state in [States.IDLE, States.ATTACK]:
		state = States.ATTACK
		animation_player.play("lp_chain")
func _lp_chain_2() -> void:
	if state in [States.IDLE, States.ATTACK]:
		state = States.ATTACK
		animation_player.play("lp_chain_2")
func lp_info() -> void: # for animation_player
	var info = {
	"size": Hitbox_type.SMALL,
	"time": 0.1,
	"push_power_ground": Vector2(100, 0),
	"push_type_ground": Enums.Push_types.NORMAL,
	"push_power_air": Vector2(100, 0),
	"push_type_air": Enums.Push_types.NORMAL,
	"hitlag_amount_ground": 0.1,
	"hitstun_amount_ground": 0.8,
	"hitlag_amount_air": 0,
	"hitstun_amount_air": 0.05,
	"screenshake_amount": Vector2(10, 0.1),
	"damage": 2,
	"type": Enums.Attack.NORMAL,
	"pos": Vector2(50, 0),
	}
	dict_to_spawn_hitbox(info)


func unblock() -> void:
	if state in [States.IDLE, States.BLOCK_STUNNED, States.BLOCK, States.ATTACK]:
		animation_player.play("unblock")
func unblock_info() -> void: # for animation_player
	var info = {
	"size": Hitbox_type.SMALL,
	"time": 0.1,
	"push_power_ground": Vector2(800, -300),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(500, -100),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0.3,
	"hitstun_amount_ground": 0.5,
	"hitlag_amount_air": 0,
	"hitstun_amount_air": 0.5,
	"screenshake_amount": Vector2(10, 0.1),
	"damage": 6,
	"type": Enums.Attack.UNBLOCK,
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
	"time": 0.3,
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


func _throw_ground() -> void:
	if state in [States.IDLE, States.BLOCK_STUNNED, States.BLOCK, States.ATTACK]:
		state = States.BLOCK
		animation_player.play("throw_ground")
		ObjectPooling.spawn_throw_spark_ground(position)
func throw_ground_info() -> void: # for animation_player
	var info = {
	"size": Hitbox_type.THROW,
	"time": 0.3,
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


func _slide() -> void:
	if state in [States.IDLE, States.BLOCK_STUNNED, States.BLOCK, States.ATTACK]:
		state = States.BLOCK
		animation_player.play("slide")
		# Put cool sfx and something here
func slide_info() -> void: # for animation_player
	var info = {
	"size": Hitbox_type.SLIDE,
	"time": 0.3,
	"push_power_ground": Vector2(500, -100),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(100, -150),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0,
	"hitstun_amount_ground": 0.5,
	"hitlag_amount_air": 0,
	"hitstun_amount_air": 0.2,
	"screenshake_amount": Vector2(0, 0),
	"damage": 2,
	"type": Enums.Attack.MOVE,
	"pos": Vector2(0, 120),
	}
	dict_to_spawn_hitbox(info)


func play_blockstunned() -> void:
	if animation_player.current_animation == "blockstunned":
		animation_player.play("blockstunned_2")
	else:
		animation_player.play("blockstunned")


#############################################################
## Signals
#############################################################
func _on_timer_timeout() -> void:
	if hp_bar.get_hp() > 0:
		_lp()


func _on_lp_range_r_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# sprite_2d.flip_h = false
		is_player_in_range_lp = true
		_on_attack_timer_timeout()
		attack_timer.start()
	elif body.is_in_group("enemy") \
		and target.position.x > position.x:
		is_enemy_in_range_lp = true


func _on_lp_range_l_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# sprite_2d.flip_h = true
		is_player_in_range_lp = true
		_on_attack_timer_timeout()
		attack_timer.start()
	elif body.is_in_group("enemy") \
		and target.position.x < position.x:
		is_enemy_in_range_lp = true


func _on_attack_01_range_r_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# sprite_2d.flip_h = false
		is_player_in_range_attack01 = true
		_on_attack_timer_timeout()
		attack_timer.start()


func _on_attack_01_range_l_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# sprite_2d.flip_h = true
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
		"lp",
		"lp_chain",
		"lp_chain_2",
		"unblock",
		"lp1_chain",
		"throw_float",
		"throw_ground",
		"slide",
		]:
		animation_player.play("idle")
		state = States.IDLE


func spawn_ded_copy() -> void:
	super.spawn_ded_copy()
	emit_signal("mango_boss_down")
	print("mango_boss_down")


func _on_attack_timer_timeout() -> void:
	if state != States.IDLE:
		return
	if randi_range(0, 1) == 0:
		return

	AttackQueue.queueing_to_attack(self)


func do_attack() -> void:
	if is_player_in_range_attack01 or is_player_in_range_lp:
		state = States.ATTACK
		var chance = randf()
		#phase1
		# if chance < 0.15:
		# 	_throw_ground()
		# elif chance < 0.30:
		# 	_throw_float()
		# elif chance < 0.65:
		# 	_lp()
		# elif chance < 1:
		# 	unblock()

		#phase2
		if chance < 0.05:
			_throw_ground()
		elif chance < 0.10:
			_throw_float()
		elif chance < 0.25:
			_lp_chain()
		elif chance < 0.40:
			_lp_chain_2()
		elif chance < 0.55:
			_lp()
		elif chance < 0.70:
			unblock()
		elif chance < 1:
			_slide()
		print(chance)
