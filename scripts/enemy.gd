extends "res://scripts/base_character.gd"

@export var target: CharacterBody2D
@export var is_notarget: bool


#############################################################
## Node Ref
#############################################################
@onready var attack_timer: Timer = $AttackTimer


enum {
	FOLLOW,
	}


#############################################################
## Config
#############################################################
# var is_face_right:bool = true
var speed: int = 600
var is_player_in_range_lp: bool = false
var is_enemy_in_range_lp: bool = false
var is_player_in_range_attack01: bool = false
var can_move: bool = true

var block_count := 0


#############################################################
## Built-in
#############################################################
func _ready() -> void:
	randomize()
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
	if state == States.IDLE:
		_facing()
		if not is_player_in_range_lp and not is_enemy_in_range_lp:
			_move(delta)
		else:
			# lerp when finding player
			_lerp_velocity_x()
			animation_player.play("idle")

	# lerp when attacking player
	if state not in [States.IDLE]:
		_lerp_velocity_x()
	_gravity(delta)
	move_and_slide()

	## Hitstun
	## Keep the stun duration while in air
	## start stun duration when on floor
	if stun_duration > 0 and \
		state in [States.HIT_STUNNED, States.WALL_BOUNCED, States.BOUNCE_STUNNED, States.GRABBED]:
		if is_on_floor():
			stun_duration -= delta
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


#############################################################
## Private Function
#############################################################
func _move( delta) -> void:
	if not can_move:
		return
	if animation_player.has_animation("walk"):
		animation_player.play("walk")
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


func _check_block_count() -> void:
	if block_count >= 3:
		# do the attack!
		if not AttackQueue.can_attack:
			return
		# Reset attack queue
		AttackQueue.start_queue_timer()
		_attack01()
		block_count = 0


#############################################################
## Helper
#############################################################
## Use in AnimationPlayer
func _add_block_count(amount: int):
	block_count += amount


func set_collision_no_hit_player() -> void:
	collision_layer = 0b00000000000000010000
	collision_mask = 0b00000000000000001100


func set_collision_no_hit_enemy() -> void:
	collision_layer = 0b00000000000000010000
	collision_mask = 0b00000000000000001101


func set_collision_normal() -> void:
	collision_layer = 0b00000000000000000010
	collision_mask = 0b00000000000000001111


func _on_bounce_together_body_entered(body: Node2D) -> void:
	if velocity.length() < 500:
		return
	## Hit other enemy
	if self.state in [States.BOUNCE_STUNNED, States.EXECUTETABLE] \
	and body.state != States.BOUNCE_STUNNED:
		printt("===bounce_together===")
		body.hitted(
			self,
			true,
			velocity / 10,
			1,
			0,
			0.5,
			Vector2.ZERO,
			1
		)


#############################################################
## Attacks
#############################################################
func _attack01() -> void: # suppress error
	pass
