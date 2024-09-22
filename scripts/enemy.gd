extends "res://scripts/base_character.gd"

@export var target: CharacterBody2D
@export var is_notarget: bool


enum {
	FOLLOW,
	}


#############################################################
## Config
#############################################################
# var is_face_right:bool = true
var speed: int = 600
var is_player_in_range_lp: bool = false
var is_player_in_range_attack01: bool = false


#############################################################
## Built-in
#############################################################
func _ready() -> void:
	gravity_power = 5000
	hp_bar.set_hp(hp)
	pass
	# $Timer.start()
	# _lp()


func _physics_process(delta: float) -> void:
	## notarget 
	if is_notarget:
		is_player_in_range_lp = false
		is_player_in_range_attack01 = false


	## wall bounce
	_check_wall_bounce()

	is_face_right = not sprite_2d.flip_h
	# _z_index_equal_to_y()
	if state == States.IDLE:
		_facing()
		_move(delta)

	if is_player_in_range_lp:
		_lp()
	elif is_player_in_range_attack01:
		_attack01()

	if state not in [States.IDLE]:
		_lerp_velocity_x()
	_gravity(delta)
	move_and_slide()

	## hitstun...
	if stun_duration > 0 and state in [States.HIT_STUNNED, States.WALL_BOUNCED, States.BOUNCE_STUNNED]:
		## remain in stun state
		stun_duration -= delta
	elif stun_duration < 0:
		# state = States.IDLE
		animation_player.play("idle")
		stun_duration = 0

	## debug
	$DebugLabel.text = "%s"%States.keys()[state]


#############################################################
## Private Function
#############################################################
func _move( delta) -> void:
	if is_instance_valid(target) and not is_notarget:
		var direction = (target.position - global_position).normalized() 
		var desired_velocity =  direction * speed
		var steering = (desired_velocity - velocity) * delta * 2.5
		velocity += steering


func _facing() -> void:
	if velocity.x > 0 :
		sprite_2d.flip_h = false
	elif velocity.x < 0 :
		sprite_2d.flip_h = true
	elif velocity.x == 0:
		pass


#############################################################
## Attack Info
#############################################################
## This whole thing is to make it easire to adjust attack info ┐(￣～￣)┌ 
## This func is used by attack moves below
func dict_to_spawn_hitbox(info: Dictionary) -> void:
	_spawn_lp_hitbox(
	info["size"],
	info["time"],
	info["push_power_ground"],
	info["push_type_ground"],
	info["push_power_air"],
	info["push_type_air"],
	info["hitlag_amount_ground"],
	info["hitstun_amount_ground"],
	info["hitlag_amount_air"],
	info["hitstun_amount_air"],
	info["screenshake_amount"],
	info["damage"],
	)


func _lp() -> void:
	if state == States.IDLE:
		animation_player.play("lp1")
func lp_info() -> void:
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
	}
	dict_to_spawn_hitbox(info)


func _attack01() -> void:
	if state == States.IDLE:
		animation_player.play("attack01_1")
func attack01_info() -> void:
	var info = {
	"size": Hitbox_size.MEDIUM,
	"time": 0.3,
	"push_power_ground": Vector2(800, 0),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(300, 0),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0,
	"hitstun_amount_ground": 0.5,
	"hitlag_amount_air": 0,
	"hitstun_amount_air": 0.5,
	"screenshake_amount": Vector2(100, 0.1),
	"damage": 3,
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


func _on_lp_range_l_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		sprite_2d.flip_h = true
		is_player_in_range_lp = true


func _on_attack_01_range_r_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		sprite_2d.flip_h = false
		var result = randi_range(0, 1)
		if result == 0:
			is_player_in_range_attack01 = true

func _on_attack_01_range_l_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		sprite_2d.flip_h = true
		var result = randi_range(0, 1)
		if result == 0:
			is_player_in_range_attack01 = true


func _on_attack_range_01r_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_in_range_attack01 = false


func _on_lp_range_r_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_in_range_lp = false


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	# if anim_name in ["lp1", "attack01_1", "hitted", "down"]:
	if anim_name in ["lp1", "attack01_1"]:
		animation_player.play("idle")
		state = States.IDLE
	if anim_name in ["ded"]:
		queue_free()
