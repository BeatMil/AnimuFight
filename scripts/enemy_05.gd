extends "res://scripts/enemy.gd"


const HITBOX_SNIPER = preload("res://nodes/hitboxes/hitbox_sniper.tscn")


func _physics_process(delta: float) -> void:
	## notarget 
	if is_notarget:
		is_player_in_range_lp = false
		is_player_in_range_attack01 = false

	## wall bounce
	_check_wall_bounce()

	if state in [States.IDLE]:
		if is_on_floor():
			# touch everything
			collision_layer = 0b00000000000000000010
			collision_mask = 0b00000000000000001111
		else:
			# no touch both player & enemy
			collision_layer = 0b00000000000000010000
			collision_mask = 0b00000000000000001100

	is_face_right = not sprite_2d.flip_h
	# _z_index_equal_to_y()
	## Hitstun
	## Keep the stun duration while in air
	## start stun duration when on floor
	if stun_duration > 0 and \
		state in [States.HIT_STUNNED, States.WALL_BOUNCED, States.BOUNCE_STUNNED, States.GRABBED]:
		if is_on_floor():
			stun_duration -= delta
			set_collision_normal()
		else:
			set_collision_no_hit_player()
	elif stun_duration < 0:
		# state = States.IDLE
		if hp_bar.get_hp() <= 0:
			queue_free()
		animation_player.play("idle")
		stun_duration = 0
		set_collision_normal()

	_check_block_count()

	## debug
	$DebugLabel.text = "%s, %s"%[States.keys()[state], animation_player.current_animation]


func look_at_player() -> void:
	sprite_2d.look_at(target.position)


func look_normal() -> void:
	sprite_2d.rotation = 0


#############################################################
## Attack Info
#############################################################
func _lp() -> void:
	if state == States.IDLE:
		animation_player.play("lp1")
func lp_info() -> void: # for animation_player
	var info = {
	"size": Hitbox_size.MEDIUM,
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
	if state in [States.IDLE, States.BLOCK_STUNNED, States.BLOCK]:
		state = States.BLOCK
		animation_player.play("attack01_1")
func attack01_info() -> void: # for animation_player
	draw_sniper_laser(target.position)
	var hit_box_sniper = HITBOX_SNIPER.instantiate()
	hit_box_sniper.push_power_ground = Vector2(500, -100)
	hit_box_sniper.push_type_ground = Enums.Push_types.KNOCKDOWN
	hit_box_sniper.push_power_air = Vector2(500, -100)
	hit_box_sniper.push_type_air = Enums.Push_types.KNOCKDOWN
	hit_box_sniper.hitstun_amount_ground = 0.2
	hit_box_sniper.hitstun_amount_air = 0.2
	hit_box_sniper.type = Enums.Attack.UNBLOCK
	hit_box_sniper.damage = 3
	hit_box_sniper.screenshake_amount = Vector2(50, 0.1)
	hit_box_sniper.self_pos = self.position
	hit_box_sniper.target_pos = target.position
	hit_box_sniper.is_hit_player = true
	hit_box_sniper.active_frame = 0.1
	add_child(hit_box_sniper)

	# var info = {
	# "size": Hitbox_size.TOWL,
	# "time": 0.3,
	# "push_power_ground": Vector2(800, -300),
	# "push_type_ground": Enums.Push_types.KNOCKDOWN,
	# "push_power_air": Vector2(300, 0),
	# "push_type_air": Enums.Push_types.KNOCKDOWN,
	# "hitlag_amount_ground": 0,
	# "hitstun_amount_ground": 0.6,
	# "hitlag_amount_air": 0,
	# "hitstun_amount_air": 0.5,
	# "screenshake_amount": Vector2(100, 0.1),
	# "damage": 3,
	# "type": Enums.Attack.THROW,
	# "pos": $HitBoxPos/TowlPos.position,
	# }
	# dict_to_spawn_hitbox(info)


func draw_sniper_laser(target_position):
	var line = Line2D.new()
	line.default_color = Color.RED
	line.width = 2
	line.points = [Vector2.ZERO, to_local(target_position)]
	add_child(line)

	# Optional: remove the laser after a short delay
	await get_tree().create_timer(0.1).timeout
	line.queue_free()

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
		animation_player.play("ded")
	if anim_name in ["ded"]:
		queue_free()


func _on_attack_timer_timeout() -> void:
	if state != States.IDLE:
		return
	if randi_range(0, 1) == 0:
		return
	if not AttackQueue.can_attack:
		return
	# Reset attack queue
	AttackQueue.start_queue_timer()

	if is_player_in_range_attack01:
		_attack01()
	if is_player_in_range_lp:
		_lp()
