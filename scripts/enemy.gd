extends "res://scripts/base_character.gd"

@export var target: CharacterBody2D
@export var air_throw_follow_pos: Marker2D
@export var is_notarget: bool


var DED_SPRITE = null


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
var is_jump_spawn: bool = false
var ground_friction: float = 0.1
var air_friction: float = 0.07

var block_count := 0
var is_bound := false


#############################################################
## Built-in
#############################################################
func _ready() -> void:
	self.tree_exited.connect(_on_tree_exited)
	$AnimationPlayer.animation_started.connect(_on_current_anim_start)
	randomize()
	gravity_power = 5000
	hp_bar.set_hp(hp)
	$ExecuteShow.text = "%s"%InputMap.action_get_events("execute")[0].as_text()
	pass
	# $Timer.start()
	# _lp()


func _physics_process(delta: float) -> void:
	if hitlag_timer > 0:
		hitlag_timer -= delta
		return

	if is_notarget:
		is_player_in_range_lp = false
		is_player_in_range_attack01 = false

	is_face_right = not sprite_2d.flip_h

	_check_wall_bounce()


	# collision_layer
	if state in [States.IDLE]:
		if is_on_floor():
			# touch everything
			collision_layer = 0b00000000000000000010
			collision_mask = 0b00000000000000001111
		else:
			# no touch both player & enemy
			collision_layer = 0b00000000000000010000
			collision_mask = 0b00000000000000001100

	# Move and Facing
	if state in [States.IDLE]:
		_facing()
		is_wall_bounced = false
		is_wall_splat =  false
		if not is_player_in_range_lp and not is_enemy_in_range_lp:
			_move(delta)
		else:
			# lerp when finding player
			_lerp_velocity_x()
			animation_player.play("idle")
			# block_count = 0

	# lerp when attacking player
	if state not in [States.IDLE]:
		_lerp_velocity_x()

	_gravity(delta)
	move_and_slide()

	## Hitstun
	## Keep the stun duration while in air
	## start stun duration when on floor
	if stun_duration >= 0 and \
		state in [States.HIT_STUNNED, States.WALL_BOUNCED, States.BOUNCE_STUNNED, States.GRABBED]:
		if is_on_floor():
			friction = ground_friction
			stun_duration -= delta
			if animation_player.current_animation == "down":
				collision_layer = 0b00000000000010000000
		else: # not on_floor
			set_collision_no_hit_all()
			friction = air_friction
	elif state == States.EXECUTETABLE:
		set_collision_no_hit_all()
	elif stun_duration < 0 and animation_player.current_animation != "wallsplat":
		if hp_bar.get_hp() <= 0:
			spawn_ded_copy()
			queue_free()
		stun_duration = 0
		animation_player.play("idle")
		state = States.IDLE
		set_collision_normal()

	_check_block_count()

	if is_on_floor() and state == States.THROWN:
		# state = States.ATTACK
		self.hitted(
			self,
			not is_face_right,
			Vector2(200, -100),
			Enums.Push_types.KNOCKDOWN,
			0,
			0.1,
			Vector2(20, 0.2),
			1,
			Enums.Attack.P_PARRY
		)

	if state in [States.GRABBED, States.THROWN]:
		_follow_pos()


	if animation_player.current_animation == "wallsplat":
		if is_on_floor():
			animation_player.play("wall_crumble")
			stun_duration = 2

	## debug
	$DebugLabel.text = "%s, %s %0.3f"%[States.keys()[state], animation_player.current_animation, stun_duration]
	# $DebugLabel.text = "%s, %s, %s, %s"%[States.keys()[state], animation_player.current_animation, attack_timer.time_left, attack_timer.is_stopped()]


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


func _follow_pos() -> void:
	if is_instance_valid(air_throw_follow_pos):
		position = air_throw_follow_pos.global_position
		print("==Follow the throw pos==")


func _facing() -> void:
	if not target:
		return
	if target.position.x > position.x:
		sprite_2d.flip_h = false
	else:
		sprite_2d.flip_h = true


func _check_block_count() -> void:
	if block_count >= 3:
		# do the attack!
			# Reset attack queue
		AttackQueue.queueing_priority(self)
		AttackQueue.queue_go()
		block_count = 0


#############################################################
## Helper
#############################################################
## Use in AnimationPlayer
func _add_block_count(amount: int):
	block_count += amount


func set_collision_no_hit_all() -> void:
	collision_layer = 0b00000000000000010000
	collision_mask = 0b00000000000000001100


func set_collision_no_hit_enemy() -> void:
	collision_layer = 0b00000000000000000010
	collision_mask = 0b00000000000000001101


func push_to_target() -> void:
	var tween = get_tree().create_tween()
	var new_pos := Vector2.ZERO
	new_pos.x = target.position.x
	new_pos.y = position.y
	tween.tween_property(self, "position", new_pos, 0.2).set_trans(Tween.TRANS_CUBIC)


func set_collision_normal() -> void:
	collision_layer = 0b00000000000000000010
	collision_mask = 0b00000000000000001111


func set_flip_h(value: bool) -> void:
	sprite_2d.flip_h = value


func toggle_flip_h() -> void:
	sprite_2d.flip_h = !sprite_2d.flip_h


func get_is_bound() -> bool:
	return is_bound


func set_is_bound(value: bool) -> void:
	is_bound = value


func spawn_ded_copy() -> void:
	var ded_copy = Sprite2D.new()
	ded_copy.texture = DED_SPRITE
	ded_copy.position = position
	ded_copy.flip_h = sprite_2d.flip_h
	ded_copy.scale = sprite_2d.scale
	get_tree().current_scene.add_child(ded_copy)


func _on_bounce_together_body_entered(body: Node2D) -> void:
	if velocity.length() < 2000:
		return
	## Hit other enemy
	if self.state in [States.BOUNCE_STUNNED, States.EXECUTETABLE, States.THROWN] \
		and body.state != States.BOUNCE_STUNNED and \
		body.animation_player.current_animation not in ["wall_crumble", "wallsplat"]:
		play_bounce_sfx()
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


func _on_current_anim_start(anim_name: String) -> void:
	if anim_name in ["idle", "walk"]:
		is_bound = false
	
	if anim_name == "execute":
		$ExecuteShow.visible = true
	else:
		$ExecuteShow.visible = false


#############################################################
## Attacks
#############################################################
func _attack01() -> void: # suppress error
	pass


func _on_tree_exited() -> void:
	if target:
		target.hp_bar.hp_up(2)
