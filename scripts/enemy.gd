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
	_move(delta)
	if state == States.IDLE:
		_facing()

	if is_player_in_range_lp:
		_lp()
	elif is_player_in_range_attack01:
		_attack01()

	if state not in [States.IDLE]:
		_lerp_velocity_x()
	_gravity(delta)
	move_and_slide()

	## debug
	$DebugLabel.text = "%s"%velocity


#############################################################
## Private Function
#############################################################
func _move( delta) -> void:
	if is_instance_valid(target) and not is_notarget:
		if state == States.IDLE:
			var direction = (target.position - global_position).normalized() 
			var desired_velocity =  direction * speed
			var steering = (desired_velocity - velocity) * delta * 2.5
			velocity += steering


func _attack01() -> void:
	if state == States.IDLE:
		animation_player.play("attack01_1")


func _lp() -> void:
	if state == States.IDLE:
		animation_player.play("lp1")


func _facing() -> void:
	if velocity.x > 0 :
		sprite_2d.flip_h = false
	elif velocity.x < 0 :
		sprite_2d.flip_h = true
	elif velocity.x == 0:
		pass


func _on_timer_timeout() -> void:
	if hp_bar.get_hp() > 0:
		_lp()


#############################################################
## Signals
#############################################################
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
	if anim_name in ["lp1", "attack01_1", "hitted", "down"]:
		animation_player.play("idle")
		state = States.IDLE
	if anim_name in ["ded"]:
		queue_free()
