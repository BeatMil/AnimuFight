extends CharacterBody2D


"""
Check flip_h for which direction character is facing
flip_h == true;  facing left
flip_h == false; facing right
"""

## Do not reorder this
## animation_player uses this
enum States {
	IDLE,
	ATTACK,
	LP1,
	LP2,
	LP3,
	HIT_STUNNED,
	BLOCK,
	PARRY,
	PARRY_SUCCESS,
	F_LP,
	AIR,
	HP,
	WALL_BOUNCED,
	BOUNCE_STUNNED,
	BLOCK_STUNNED,
	DODGE,
	DODGE_SUCCESS,
	THROW_BREAKABLE,
	THROWN,
	EXECUTETABLE,
	EXECUTE,
	IFRAME,
	ARMOR,
	JF_SHOULDER,
	TA,
	SPELL,
	TAN,
	NOBUFFER,
	GRABSTANCE,
	GRABBED,
	PUNISHABLE,
	AIR_SPD,
	DASH,
	WALL_THROW,
	DOWN_HP,
	AIR_LP1,
	}


enum Hitbox_type {
	SMALL,
	MEDIUM,
	LARGE,
	HAMMER,
	TOWL,
	THROW,
	BURST,
	EXECUTE,
	METEO,
	AIR_THROW,
	BOUND,
	WAILL_THROW,
	GROUND_THROW,
	}


#############################################################
## Preloads
#############################################################
const HITBOX_LP_SMALL = preload("res://nodes/hitboxes/hitbox_small.tscn")
const HITBOX_LP_MEDIUM = preload("res://nodes/hitboxes/hitbox_lp.tscn")
const HITBOX_LP_LARGE = preload("res://nodes/hitboxes/hitbox_lp2.tscn")
const HITBOX_HAMMER = preload("res://nodes/hitboxes/hitbox_hammer.tscn")
const HITBOX_BURST = preload("res://nodes/hitboxes/hitbox_burst.tscn")
const HITBOX_TOWL = preload("res://nodes/hitboxes/hitbox_towl.tscn")
const HITBOX_THROW = preload("res://nodes/hitboxes/hitbox_throw.tscn")
const HITBOX_EXE = preload("res://nodes/hitboxes/hitbox_execute.tscn")
const HITBOX_METEO = preload("res://nodes/hitboxes/hitbox_meteo_crash.tscn")
const HITBOX_AIR_THROW = preload("res://nodes/hitboxes/hitbox_air_throw.tscn")
const HITBOX_GROUND_THROW = preload("res://nodes/hitboxes/hitbox_ground_throw.tscn")
const HITBOX_BOUND = preload("res://nodes/hitboxes/hitbox_bound.tscn")
const HIT_2 = preload("res://media/sfxs/Hit2.wav")
const SLOW_MO_START = preload("res://media/sfxs/slow_mo_start.wav")
const SLOW_MO_END = preload("res://media/sfxs/slow_mo_end.wav")
const HIT_BOUNCE = preload("res://media/sfxs/Landing_RawMeat02.wav")
const IFRAME_HIT = preload("res://media/sfxs/Landing_Meat03.wav")

#############################################################
## Node Ref
#############################################################
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var lp_pos: Marker2D = $HitBoxPos/LpPos
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var hp_bar: TextureProgressBar = $HpBar
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


#############################################################
## Config
#############################################################
var state = States.IDLE
var move_speed: int = 100000
var move_speed_vert: int = 20000
var is_face_right:bool = true
var gravity_power = 10000
var jump_power = 250000
@export var hp: int = 5
var friction: float = 0.1
var block_rate = 5

## wall bounce helper
var is_touching_wall_left: bool = false
var is_touching_wall_right: bool = false

## hitstun helper
var stun_duration: float = 0

var hitlag_timer: float = 0

var is_ded := false
var is_wall_bounced := false
var is_wall_splat := false


#############################################################
## Built-in
#############################################################
### Built-in can be overide.... (っ˘̩╭╮˘̩)っ 
func _ready() -> void:
	pass


### Seems like it doesn't run the process functions when used as inheritance
func _physics_process(_delta: float) -> void:
	pass


#############################################################
## Private function
#############################################################
func _z_index_equal_to_y() -> void:
	z_index = int(position.y)


func _lerp_velocity_x() -> void:
	velocity = velocity.lerp(Vector2(0, velocity.y), friction)


func _lerp_velocity_y() -> void:
	velocity = velocity.lerp(Vector2(velocity.x, 0), friction)


func _gravity(delta) -> void:
	if not is_on_floor():
		velocity += Vector2(0, gravity_power*delta)


func _check_wall_bounce() -> void:
	if state not in [States.BOUNCE_STUNNED, States.THROWN]:
		return

	if is_touching_wall_left or is_touching_wall_right:
		animation_player.stop(true)
		if is_wall_splat:
			animation_player.play("down")
			set_collision_no_hit_all()
			var push_power = Vector2(1000, 100) if is_touching_wall_left else Vector2(-1000, 100)
			_push_direct(push_power)
			get_tree().current_scene.get_node_or_null("Player/Camera").start_screen_shake(10, 0.1)
			hitlag(0.3)
		elif is_wall_bounced:
			get_tree().current_scene.get_node_or_null("Player/Camera").start_screen_shake(40, 0.3)
			hitlag(0.5)
			animation_player.play("wallsplat")
			velocity = Vector2.ZERO
			is_wall_splat = true
			# var tween = get_tree().create_tween()
			# tween.tween_property(self, "position", position, 0.9)
			# tween.tween_property(self, "velocity", Vector2.ZERO, 0)
		else:
			is_wall_bounced = true
			var push_power = Vector2(400, -100) if is_touching_wall_left else Vector2(-400, -100)
			_push_direct(push_power)
			get_tree().current_scene.get_node_or_null("Player/Camera").start_screen_shake(10, 0.1)
			hitlag(0.3)
			animation_player.play("down")
			set_collision_no_hit_all()
	
		hp_bar.hp_down(1)
		state = States.WALL_BOUNCED
		# is_touching_wall_left = false
		# is_touching_wall_right = false
		play_bounce_sfx()
		ObjectPooling.spawn_hitSpark_1(position + Vector2(0, randi_range(-30, -80)))


func _move_left(delta) ->  void:
	velocity = Vector2(-move_speed * delta, velocity.y)
	sprite_2d.flip_h = true


func _move_right(delta) ->  void:
	velocity = Vector2(move_speed * delta, velocity.y)
	sprite_2d.flip_h = false


func _move_up(delta) ->  void:
	velocity = Vector2(velocity.x, -move_speed_vert*delta)


func _move_down(delta) ->  void:
	velocity = Vector2(velocity.x, move_speed_vert*delta)


func _jump(delta) -> void:
	if is_on_floor():
		velocity += Vector2(0, -jump_power*delta)
		animation_player.play("jump")


func _block() ->  void:
	animation_player.play("block")


"""
animation_player uses
"""
func _spawn_lp_hitbox(
	_size: Hitbox_type,
	_time: float = 0.1,
	_push_power_ground: Vector2 = Vector2(20, 0),
	_push_type_ground: Enums.Push_types = Enums.Push_types.NORMAL,
	_push_power_air: Vector2 = Vector2(100,-150),
	_push_type_air: Enums.Push_types = Enums.Push_types.NORMAL,
	_hitlag_amount_ground: float = 0,
	_hitstun_amount_ground: float = 0.5,
	_hitlag_amount_air: float = 0,
	_hitstun_amount_air: float = 0.5,
	_screenshake_amount: Vector2 = Vector2(0, 0),
	_damage: int = 1,
	_type: int = 0,
	_pos: Vector2 = Vector2(168, 0),
	_zoom: Vector2 = Vector2(0.8, 0.8),
	_zoom_duration: float = 0.1,
	_slow_mo_on_block: Vector2 = Vector2.ZERO,
	_pos_direct: Vector2 = Vector2.ZERO
	) -> void:

	var hitbox: Node2D

	match _size:
		Hitbox_type.SMALL:
			hitbox = HITBOX_LP_SMALL.instantiate()
		Hitbox_type.MEDIUM:
			hitbox = HITBOX_LP_MEDIUM.instantiate()
		Hitbox_type.LARGE:
			hitbox = HITBOX_LP_LARGE.instantiate()
		Hitbox_type.HAMMER:
			hitbox = HITBOX_HAMMER.instantiate()
		Hitbox_type.TOWL:
			hitbox = HITBOX_TOWL.instantiate()
			## Flip towl sprite here so that 
			## it doesn't interfere with others
			if sprite_2d.flip_h: 
				hitbox.scale.x = -1
		Hitbox_type.THROW:
			hitbox = HITBOX_THROW.instantiate()
		Hitbox_type.BURST:
			hitbox = HITBOX_BURST.instantiate()
		Hitbox_type.EXECUTE:
			hitbox = HITBOX_EXE.instantiate()
		Hitbox_type.METEO:
			hitbox = HITBOX_METEO.instantiate()
		Hitbox_type.AIR_THROW:
			hitbox = HITBOX_AIR_THROW.instantiate()
		Hitbox_type.GROUND_THROW:
			hitbox = HITBOX_GROUND_THROW.instantiate()
		Hitbox_type.BOUND:
			hitbox = HITBOX_BOUND.instantiate()
		_:
			hitbox = HITBOX_LP_MEDIUM.instantiate()

	if sprite_2d.flip_h: ## facing left
		hitbox.position = Vector2(-_pos.x, _pos.y)
	else: ## facing right
		hitbox.position = Vector2(_pos.x, _pos.y)
	if _pos_direct:
		hitbox.position = _pos_direct
	
	## Set hitbox collision target
	if self.is_in_group("player"):
		hitbox.is_hit_enemy = true
	elif self.is_in_group("enemy"):
		hitbox.is_hit_player = true
	
	## Set push_type and power
	hitbox.push_type_ground = _push_type_ground
	hitbox.push_power_ground = _push_power_ground
	hitbox.push_type_air = _push_type_air
	hitbox.push_power_air = _push_power_air
	hitbox.hitlag_amount_ground = _hitlag_amount_ground
	hitbox.hitstun_amount_ground = _hitstun_amount_ground
	hitbox.hitlag_amount_air = _hitlag_amount_air
	hitbox.hitstun_amount_air = _hitstun_amount_air
	hitbox.screenshake_amount = _screenshake_amount
	hitbox.damage = _damage
	hitbox.type = _type
	hitbox.zoom = _zoom
	hitbox.zoom_duration = _zoom_duration
	hitbox.slow_mo_on_block = _slow_mo_on_block

	hitbox.active_frame = _time

	add_child(hitbox)


func _set_state(new_state: int) -> void:
	state = States.values()[new_state]


"""
animation_player uses
"""
func _push_x_old(power: Vector2) -> void:
	var tween = get_tree().create_tween()
	var new_pos := Vector2.ZERO
	if sprite_2d.flip_h: ## facing left
		new_pos = Vector2(position.x-power.x, position.y+power.y)
	else: ## facing left
		new_pos = Vector2(position.x+power.x, position.y+power.y)
	tween.tween_property(self, "position", new_pos, 0.2).set_trans(Tween.TRANS_CUBIC)


func _push_x_direct_old(pixel: int) -> void:
	var tween = get_tree().create_tween()
	var new_pos := Vector2.ZERO
	new_pos = Vector2(position.x+pixel, position.y)
	tween.tween_property(self, "collision_mask", 0b00000000000000001011, 0)
	tween.tween_property(self, "position", new_pos, 0.2).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "collision_mask", 0b00000000000000001111, 0)


func _push_x(power: int) -> void:
	var multiplier = 10
	if sprite_2d.flip_h: ## facing left
		velocity += Vector2(power*-multiplier, 0)
	else: ## facing left
		velocity += Vector2(power*multiplier, 0)


func _push_x_direct(power: int) -> void:
	var multiplier = 10
	velocity += Vector2(power*multiplier, 0)


func _push(power: Vector2) -> void:
	var multiplier = 10
	if sprite_2d.flip_h: ## facing left
		velocity = power * Vector2(-multiplier, multiplier)
		# velocity += Vector2(power*-multiplier, 0)
	else: ## facing left
		pass
		velocity = power * Vector2(multiplier, multiplier)


func _push_direct(power: Vector2) -> void:
	var multiplier = 10
	velocity = power * multiplier


func hitlag(_amount: float = 0.0) -> void:
	hitlag_timer = _amount


#############################################################
## Public functions
#############################################################
"""
hitbox.gd uses this
"""
### Turn it into class ! Wowww
func hitted(
	_attacker: Object,
	is_push_to_the_right: bool,
	push_power: Vector2 = Vector2(20, 0),
	push_type: int = 0,
	hitlag_amount: float = 0,
	hitstun_amount: float = 0.5,
	_screenshake_amount: Vector2 = Vector2(10, 0.1),
	_damage: int = 1,
	_type: int = 0,
	_zoom: Vector2 = Vector2(0, 0),
	_zoom_duration: float = 0.1,
	slow_mo_on_block: Vector2 = Vector2(0, 0)
	) -> void:
	## TANK
	if is_in_group("enemy") and _type not in [
		Enums.Attack.UNBLOCK,
		Enums.Attack.P_AIR_THROW,
		Enums.Attack.P_WALL_THROW,
		] and state in [States.IDLE]:
	# if is_in_group("enemy") and _type not in [Enums.Attack.UNBLOCK, ] and state in [States.IDLE]:
		if randi_range(1, 10) <= block_rate:
			state = States.BLOCK

	## BLOCK & ARMOR
	if state in [States.BLOCK, States.BLOCK_STUNNED, States.ARMOR, States.PARRY_SUCCESS] and \
		_type in [Enums.Attack.NORMAL, Enums.Attack.P_PARRY]:
		# if state == States.ARMOR:
		# 	hp_bar.hp_down(_damage)
		if has_method("_add_block_count"):
			self._add_block_count(1)
		if self.name == "MangoBoss":
			play_blockstunned()
		else:
			animation_player.stop()
			animation_player.play("blockstunned")
		# hp_bar.hp_down(_damage/2)
		block_effect_helper(
			hitstun_amount,
			is_push_to_the_right,
			push_power,
			hitlag_amount,
			_screenshake_amount,
			_attacker)

	## Parry & Parry Success
	elif state in [States.PARRY] and _type == Enums.Attack.NORMAL:
		animation_player.play("parry_success")
		if _attacker.position.x < self.position.x:
			sprite_2d.flip_h = true
		else:
			sprite_2d.flip_h = false
		_attacker.hitted(
			self,
			is_face_right,
			Vector2(20, 0),
			0,
			0,
			1,
			Vector2(10, 0.1),
			1,
			Enums.Attack.P_PARRY
		)
		# print_rich("[color=pink][b]COOL SLOW MO!![/b][/color]", slow_mo_on_block)
		if slow_mo_on_block:
			_slow_moion(slow_mo_on_block.x, slow_mo_on_block.y)
			if get_tree().current_scene.get_node_or_null("Player/Camera"):
				get_tree().current_scene.get_node_or_null(
				"Player/Camera").zoom_zoom(_zoom, _zoom_duration)
			else:
				print_debug("_zoom can't find player/camera")

	## DODGE & DODGE_SUCCESS
	elif state in [States.DODGE, States.DODGE_SUCCESS] and _type not in [Enums.Attack.THROW_GROUND, Enums.Attack.THROW_FLOAT]:
		if _type == Enums.Attack.UNBLOCK:
			animation_player.play("dodge_success_zoom")
		else:
			animation_player.play("dodge_success")

	## Player command grab (super)
	elif _type == Enums.Attack.P_THROW:
		if _attacker.throwee:
			return
		else:
			_attacker.throwee = self
		_attacker.state = States.IFRAME
		_attacker.animation_player.play("wall_abel_combo2")
		state = States.GRABBED
		animation_player.play("throw_stunned")
		self.air_throw_follow_pos = _attacker.give_wall_throw_pos()
		await get_tree().create_timer(0.32).timeout
		if _attacker.sprite_2d.flip_h:
			_push_direct(Vector2(-600, -150))
		else:
			_push_direct(Vector2(600, -150))
		self.air_throw_follow_pos = null

	## Player air grab hits
	elif _type == Enums.Attack.P_AIR_THROW and not is_on_floor():
		if _attacker.throwee:
			return
		else:
			_attacker.throwee = self
		state = States.GRABBED
		animation_player.play("throw_stunned")
		self.air_throw_follow_pos = _attacker.give_air_throw_pos()
		_attacker.animation_player.play("air_spd")
		stun_duration = hitstun_amount
	elif _type == Enums.Attack.P_AIR_THROW and is_on_floor():
		## make air throw whiff
		pass
	## Player Wall throw hits
	elif _type == Enums.Attack.P_WALL_THROW and \
		animation_player.current_animation in ["wallsplat", "wall_crumble"]:
		self.air_throw_follow_pos = _attacker.give_wall_throw_pos()
		state = States.GRABBED
		animation_player.play("throw_stunned")
		_attacker.animation_player.play("wall_abel_combo")
	elif _type == Enums.Attack.P_GROUND_THROW or \
		(_type == Enums.Attack.P_WALL_THROW and \
		state in [States.HIT_STUNNED, States.BOUNCE_STUNNED, States.WALL_BOUNCED]):
		if _attacker.throwee:
			return
		else:
			_attacker.throwee = self

		self.air_throw_follow_pos = _attacker.give_wall_throw_pos()
		_attacker.state = States.HIT_STUNNED ## whyy? but it works!
		_attacker.animation_player.play("wall_throw")
		state = States.GRABBED
		animation_player.play("thrown")
		await get_tree().create_timer(0.3).timeout
		self.air_throw_follow_pos = null
		match _attacker.is_pressing_right():
			0: #neutral
				self.hitted(
					self,
					_attacker.is_face_right,
					Vector2(0, 200),
					1,
					0,
					1,
					Vector2(0, 0.1),
					2,
					Enums.Attack.NORMAL
				)
				_attacker.animation_player.play("place_enemy")
			1: # Left
				_push_direct(Vector2(-900, -100))
				_attacker.sprite_2d.flip_h = true
			2: # Right
				_push_direct(Vector2(900, -100))
				_attacker.sprite_2d.flip_h = false
		if is_touching_wall_left or is_touching_wall_right:
			print("==NANI==")
			_attacker._push_x(-400)
	## make wall throw whiff
	elif _type == Enums.Attack.P_WALL_THROW:
		pass
	## Spawn blockspark on IFRAME
	elif state in [States.IFRAME, States.EXECUTE, States.AIR_SPD]:
		ObjectPooling.spawn_iframe_spark(position + Vector2(0, randi_range(-30, -80)))
		play_iframe_hit_sfx()
	elif _type in [Enums.Attack.THROW_GROUND, Enums.Attack.THROW_FLOAT]:
		state = States.THROW_BREAKABLE # Keep this here otherwise throw not work
		set_thrower(_attacker)

		if _type == Enums.Attack.THROW_GROUND:
			animation_player.play("throw_stunned_ground")
		else:
			animation_player.play("throw_stunned_float")

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
		# Play glass break vfx
		if state in [
			States.BLOCK,
			States.PARRY,
			States.PARRY_SUCCESS,
		] and _type == Enums.Attack.UNBLOCK:
			ObjectPooling.spawn_glass_spark(position + Vector2(0, randi_range(-30, -80)))
		else:
			ObjectPooling.spawn_hitSpark_1(position + Vector2(0, randi_range(-30, -80)))
		# Death Zone
		if _attacker.is_in_group("death_zone"):
			animation_player.stop(true)
			animation_player.play("ded")
			stun_duration = hitstun_amount
			state = States.BOUNCE_STUNNED
			# set_collision_no_hit_player()
		# Hp <= 0
		elif hp_bar.get_hp() <= 0:
			if push_type in [
			Enums.Push_types.KNOCKDOWN,
			Enums.Push_types.EXECUTE,
			] and state == States.EXECUTETABLE:
				animation_player.stop(true)
				animation_player.play("ded")
				stun_duration = hitstun_amount
				# set_collision_no_hit_player()
			elif is_ded and state != States.EXECUTETABLE:
				animation_player.stop(true)
				animation_player.play("down")
				stun_duration = hitstun_amount
				# set_collision_no_hit_player()
			else:
				state = States.HIT_STUNNED
				animation_player.stop(true)
				animation_player.play("execute")
				is_ded = true
		# Hitstunned or down
		else:
			animation_player.stop(true)
			match push_type:
				0: ## NORMAL
					state = States.HIT_STUNNED
					animation_player.play("hitted")
				1: ## KNOCKDOWN
					state = States.BOUNCE_STUNNED
					animation_player.play("down")
				2: ## EXECUTE
					state = States.BOUNCE_STUNNED
					animation_player.play("down")
				_:
					animation_player.play("hitted")
			stun_duration = hitstun_amount
		# Push direction (Left/Right)
		if is_push_to_the_right:
			_push_direct(push_power)
		else:
			_push_direct(Vector2(-push_power.x, push_power.y))
		# Hitlag
		if hitlag_amount:
			hitlag(hitlag_amount)
			_attacker.hitlag(hitlag_amount)
		# Screenshake
		if _screenshake_amount:
			if get_tree().current_scene.get_node_or_null("Player/Camera"):
				get_tree().current_scene.get_node_or_null("Player/Camera"). \
				start_screen_shake(_screenshake_amount.x, _screenshake_amount.y)
			else:
				print_debug("screenshake can't find player/camera")
		# Zoom
		if _zoom:
			if get_tree().current_scene.get_node_or_null("Player/Camera"):
				get_tree().current_scene.get_node_or_null(
				"Player/Camera").zoom(_zoom, _zoom_duration)
			else:
				print_debug("_zoom can't find player/camera")
		# Player Parries
		if _type == Enums.Attack.P_PARRY:
			$AudioStreamPlayer2.stream = HIT_2
			$AudioStreamPlayer2.play()


## This whole thing is to make it easire to adjust attack info ┐(￣～￣)┌ 
## This func is used by attack moves below
func dict_to_spawn_hitbox(info: Dictionary) -> void:
	_spawn_lp_hitbox(
	info.get("size", Hitbox_type.MEDIUM),
	info.get("time", 0.1),
	info.get("push_power_ground", Vector2(50, 0)),
	info.get("push_type_ground", Enums.Push_types.NORMAL),
	info.get("push_power_air", Vector2(100, -150)),
	info.get("push_type_air", Enums.Push_types.KNOCKDOWN),
	info.get("hitlag_amount_ground", 0),
	info.get("hitstun_amount_ground", 0.5),
	info.get("hitlag_amount_air", 0),
	info.get("hitstun_amount_air", 0.5),
	info.get("screenshake_amount", Vector2(0, 0)),
	info.get("damage", 1),
	info.get("type", Enums.Attack.NORMAL),
	info.get("pos", Vector2(168, 0)),
	info.get("zoom", Vector2(0, 0)),
	info.get("zoom_duration", 0.1),
	info.get("slow_mo_on_block", Vector2.ZERO),
	info.get("pos_direct", Vector2.ZERO)
	)


#############################################################
## Helper
#############################################################
func _remove_collision() -> void:
	if is_instance_valid(collision_shape_2d):
		collision_shape_2d.queue_free()


# AnimationPlayer
func _show_attack_indicator(type: int) -> void:
	ObjectPooling.spawn_attack_type_indicator(type, self.position)


func _slow_moion(level, length) -> void:
	GlobalSoundPlayer.stream = SLOW_MO_START
	GlobalSoundPlayer.play()
	Engine.time_scale = level
	await get_tree().create_timer(length/level).timeout
	Engine.time_scale = 1.0
	GlobalSoundPlayer.stream = SLOW_MO_END
	GlobalSoundPlayer.play()


func _slow_moion_no_sfx(level, length) -> void:
	Engine.time_scale = level
	await get_tree().create_timer(length/level).timeout
	Engine.time_scale = 1.0


func play_bounce_sfx() -> void:
	$AudioStreamPlayer2.stream = HIT_BOUNCE
	$AudioStreamPlayer2.pitch_scale = randf_range(0.8, 1.2)
	$AudioStreamPlayer2.play()


func play_iframe_hit_sfx() -> void:
	$AudioStreamPlayer2.stream = IFRAME_HIT
	$AudioStreamPlayer2.pitch_scale = randf_range(0.8, 1.2)
	$AudioStreamPlayer2.play()


# func set_collision_no_hit_player() -> void: # suppress error
# 	pass
# 	collision_layer = 0b00000000000000010000
# 	collision_mask = 0b00000000000000001100

func	set_collision_no_hit_all():
	pass

func _add_block_count(amount: int):
	pass

func set_thrower(the_guy: CharacterBody2D) -> void:
	pass


func play_blockstunned():
	pass


func block_effect_helper(
	hitstun_amount,
	is_push_to_the_right,
	push_power,
	hitlag_amount,
	_screenshake_amount,
	_attacker
	) -> void:
	stun_duration = hitstun_amount/2
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
	ObjectPooling.spawn_blockSpark_1(position + Vector2(0, randi_range(-30, -80)))
