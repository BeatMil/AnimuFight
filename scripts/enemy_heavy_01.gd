extends "res://scripts/enemy.gd"


@onready var enemy_04_hammer: Sprite2D = $HammerPivot/Enemy04Hammer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var clank_noise = preload("res://media/sfxs/high-clank.ogg")


func _ready() -> void:
	super._ready()
	block_rate = 10
	# DED_SPRITE = preload("res://media/sprites/char2/enemy01_down.png")


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


func _attack01() -> void:
	if state in [States.IDLE, States.BLOCK_STUNNED, States.BLOCK, States.ATTACK]:
		animation_player.play("attack01_1")
func attack01_info() -> void: # for animation_player
	var info = {
	"size": Hitbox_type.BOUND,
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
	"type": Enums.Attack.NORMAL,
	"pos": Vector2(400, 0),
	}
	dict_to_spawn_hitbox(info)


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
		"blockstunned",
		"hitted",
		]:
		animation_player.play("idle")
		state = States.IDLE
	if anim_name in ["ded"]:
		spawn_ded_copy()
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
		set_collision_normal()
