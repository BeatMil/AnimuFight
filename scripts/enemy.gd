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
var is_player_in_range_attack01: bool = false


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

	is_face_right = not sprite_2d.flip_h
	# _z_index_equal_to_y()
	if state == States.IDLE:
		_facing()
		if not is_player_in_range_lp:
			_move(delta)
		else:
			_lerp_velocity_x()

	# if is_player_in_range_lp:
	# 	_lp()
	# elif is_player_in_range_attack01:
	# 	_attack01()

	if state not in [States.IDLE]:
		_lerp_velocity_x()
	_gravity(delta)
	move_and_slide()

	## Hitstun
	## Keep the stun duration while in air
	## start stun duration when on floor
	if stun_duration > 0 and \
		state in [States.HIT_STUNNED, States.WALL_BOUNCED, States.BOUNCE_STUNNED]:
		if is_on_floor():
			stun_duration -= delta
		collision_layer = 0b00000000000000010000
		collision_mask = 0b00000000000000001100
	elif stun_duration < 0:
		# state = States.IDLE
		if hp_bar.get_hp() <= 0:
			queue_free()
		animation_player.play("idle")
		collision_layer = 0b00000000000000000010
		collision_mask = 0b00000000000000001111
		stun_duration = 0

	## debug
	$DebugLabel.text = "%s, %s"%[States.keys()[state], animation_player.current_animation]


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
## Helper
#############################################################
func _show_attack_indicator(type: int) -> void:
	ObjectPooling.spawn_attack_type_indicator(type, self.position)


func _on_bounce_together_body_entered(body: Node2D) -> void:
	print(self.name,self.state,"-->", body.name, body.state," ", velocity.length())
	if velocity.length() < 1000:
		return
	if self.state in [States.BOUNCE_STUNNED] and body.state != States.BOUNCE_STUNNED:
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
