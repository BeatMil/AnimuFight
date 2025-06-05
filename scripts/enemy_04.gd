extends "res://scripts/enemy.gd"
@onready var enemy_04_hammer: Sprite2D = $HammerPivot/Enemy04Hammer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var clank_noise = preload("res://media/sfxs/high-clank.ogg")


#############################################################
## Private function
#############################################################
func return_hammer():
	var tween = get_tree().create_tween()
	tween.tween_property(enemy_04_hammer, "rotation_degrees", 0, 0.2).set_trans(Tween.TRANS_CUBIC)


func play_metal_clank_random_pitch():
	audio_stream_player.stream = clank_noise
	audio_stream_player.pitch_scale = randf_range(0.9, 1.1)
	audio_stream_player.play()


#############################################################
## Attack Info
#############################################################
func _lp() -> void:
	if state == States.IDLE:
		animation_player.play("lp1")
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
	"damage": 1,
	"type": Enums.Attack.THROW,
	}
	dict_to_spawn_hitbox(info)


func _attack01() -> void:
	if state in [States.IDLE, States.BLOCK_STUNNED, States.BLOCK, States.ATTACK]:
		state = States.BLOCK
		animation_player.play("attack01_1")
func attack01_info() -> void: # for animation_player
	var info = {
	"size": Hitbox_type.HAMMER,
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
	"damage": 5,
	"type": Enums.Attack.NORMAL,
	"pos": $HitBoxPos/LpPos.position,
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


func _on_lp_range_l_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		sprite_2d.flip_h = true
		is_player_in_range_lp = true
		_on_attack_timer_timeout()
		attack_timer.start()


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


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	# if anim_name in ["lp1", "attack01_1", "hitted", "down"]:
	if anim_name in ["lp1", "attack01_1"]:
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
		_lp()


func hitted(
	_attacker: Object,
	is_push_to_the_right: bool,
	push_power: Vector2 = Vector2(20, 0),
	push_type: int = 0,
	hitlag_amount: float = 0,
	hitstun_amount: float = 0.5,
	_screenshake_amount: Vector2 = Vector2(100, 0.1),
	_damage: int = 1,
	_type: int = 0,
	_zoom: Vector2 = Vector2(0, 0),
	_zoom_duration: float = 0.1,
	slow_mo_on_block: Vector2 = Vector2(0, 0)
	) -> void:
	## TANK
	if is_in_group("enemy") and _type != Enums.Attack.UNBLOCK and state not in [
		States.HIT_STUNNED,
		States.EXECUTETABLE,
		States.BOUNCE_STUNNED,
		States.ARMOR,
		States.ATTACK,
		States.GRABBED,
		]:
		if is_in_group("tank") or randi_range(0, 1) == 0:
			state = States.BLOCK
			animation_player.stop()
			animation_player.play("blockstunned")

	## Parry & Parry Success
	if state in [States.PARRY, States.PARRY_SUCCESS] and _type == Enums.Attack.NORMAL:
		animation_player.play("parry_success")
		_attacker.hitted(
			self,
			is_face_right,
			Vector2(20, 0),
			0,
			0,
			1,
			Vector2(10, 0.1),
			1,
			Enums.Attack.UNBLOCK
		)
	## BLOCK & ARMOR
	elif state in [States.BLOCK, States.BLOCK_STUNNED, States.ARMOR] and _type == Enums.Attack.NORMAL:
		if state == States.ARMOR:
			hp_bar.hp_down(_damage)
		elif is_in_group("player"):
			hp_bar.hp_down(_damage/2)
		else:
			animation_player.stop()
			animation_player.play("blockstunned")
		stun_duration = hitstun_amount/4
		if is_push_to_the_right:
			_push_direct(push_power/2)
		else:
			_push_direct(Vector2(-push_power.x, push_power.y) / 2)
		if hitlag_amount:
			hitlag(hitlag_amount)
			_attacker.hitlag(hitlag_amount)
		if _screenshake_amount:
			if get_tree().current_scene.get_node_or_null("Player/Camera"):
				get_tree().current_scene.get_node_or_null("Player/Camera"). \
				start_screen_shake(_screenshake_amount.x, _screenshake_amount.y)
		if is_in_group("tank"):
			ObjectPooling.spawn_blockSpark_2(position)
		else:
			ObjectPooling.spawn_blockSpark_1(position)

	## DODGE & DODGE_SUCCESS
	elif state in [States.DODGE, States.DODGE_SUCCESS] and _type != Enums.Attack.THROW:
		if _type == Enums.Attack.UNBLOCK:
			animation_player.play("dodge_success_zoom")
		else:
			animation_player.play("dodge_success")

	## Spawn blockspark on IFRAME
	elif state in [States.IFRAME, States.EXECUTE]:
		ObjectPooling.spawn_blockSpark_1(position)
	elif _type == Enums.Attack.THROW:
		state = States.THROW_BREAKABLE # Keep this here otherwise throw not work
		animation_player.play("throw_stunned")

	## Player grab hits
	elif _type == Enums.Attack.P_THROW:
		# Player enter grab stance
		if _attacker.has_method("enter_grab_stance"):
			_attacker.enter_grab_stance()
			_attacker.set_grabbed_enemy(self)

		# Enemy got grabbed into position
		animation_player.play("throw_stunned")
		self.can_move = false
		var grab_pos :Vector2
		if _attacker.sprite_2d.flip_h:
			grab_pos = _attacker.get_node_or_null("HitBoxPos/GrabPosL").global_position
		else:
			grab_pos = _attacker.get_node_or_null("HitBoxPos/GrabPosR").global_position
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", grab_pos, 0.1).set_trans(Tween.TRANS_CUBIC)
		await get_tree().create_timer(0.1).timeout
		set_physics_process(false)

	##################
	# - Do damage
	# - play animation base on push type
	# - hit stun
	# - hit lag
	# - screenshake
	# - zoom
	# - Too many things T^T
	##################
	else: # Do damage and push type
		hp_bar.hp_down(_damage)
		if _attacker.is_in_group("death_zone"):
			animation_player.stop(true)
			animation_player.play("ded")
			stun_duration = hitstun_amount/4
			state = States.BOUNCE_STUNNED
		elif hp_bar.get_hp() <= 0:
			if push_type in [
			Enums.Push_types.KNOCKDOWN,
			Enums.Push_types.EXECUTE] and state == States.EXECUTETABLE:
				animation_player.stop(true)
				animation_player.play("ded")
				stun_duration = hitstun_amount
			else:
				state = States.HIT_STUNNED
				animation_player.stop(true)
				animation_player.play("execute")
		else:
			match push_type:
				0: ## NORMAL
					animation_player.stop(true)
					stun_duration = hitstun_amount/4
					state = States.HIT_STUNNED
					animation_player.play("hitted")
				1: ## KNOCKDOWN
					animation_player.stop(true)
					animation_player.play("down")
					stun_duration = hitstun_amount/4
					state = States.BOUNCE_STUNNED
				2: ## EXECUTE
					animation_player.stop(true)
					if hp_bar.get_hp() > 0:
						animation_player.play("down")
						state = States.BOUNCE_STUNNED
					else:
						animation_player.play("ded")
						state = States.BOUNCE_STUNNED
					stun_duration = hitstun_amount
				_:
					animation_player.stop(true)
					animation_player.play("hitted")
					stun_duration = hitstun_amount/4

		if is_push_to_the_right:
			if is_in_group("tank"):
				_push_direct(push_power/3)
			else:
				_push_direct(push_power)
		else:
			if is_in_group("tank"):
				_push_direct(Vector2(-push_power.x, push_power.y)/3)
			else:
				_push_direct(Vector2(-push_power.x, push_power.y))
		if hitlag_amount:
			hitlag(hitlag_amount)
			_attacker.hitlag(hitlag_amount)
		if _screenshake_amount:
			if get_tree().current_scene.get_node_or_null("Player/Camera"):
				get_tree().current_scene.get_node_or_null("Player/Camera"). \
				start_screen_shake(_screenshake_amount.x, _screenshake_amount.y)
			else:
				print_debug("screenshake can't find player/camera")
		if _zoom:
			if get_tree().current_scene.get_node_or_null("Player/Camera"):
				get_tree().current_scene.get_node_or_null(
				"Player/Camera").zoom(_zoom, _zoom_duration)
			else:
				print_debug("_zoom can't find player/camera")

		ObjectPooling.spawn_hitSpark_1(position)
