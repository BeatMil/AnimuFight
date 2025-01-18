extends "res://scripts/enemy.gd"

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
	var info = {
	"size": Hitbox_size.TOWL,
	"time": 0.3,
	"push_power_ground": Vector2(800, -300),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(300, 0),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0,
	"hitstun_amount_ground": 0.6,
	"hitlag_amount_air": 0,
	"hitstun_amount_air": 0.5,
	"screenshake_amount": Vector2(100, 0.1),
	"damage": 3,
	"type": Enums.Attack.THROW,
	"pos": $HitBoxPos/TowlPos.position,
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
	if randi_range(0, 1) == 0:
		return

	if is_player_in_range_attack01:
		_attack01()
	if is_player_in_range_lp:
		_lp()
