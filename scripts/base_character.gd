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
	}


enum Hitbox_size {
	SMALL,
	MEDIUM,
	LARGE,
	TOWL,
	BURST,
	EXECUTE,
	}


#############################################################
## Preloads
#############################################################
const HITBOX_LP_MEDIUM = preload("res://nodes/hitboxes/hitbox_lp.tscn")
const HITBOX_LP_LARGE = preload("res://nodes/hitboxes/hitbox_lp2.tscn")
const HITBOX_BURST = preload("res://nodes/hitboxes/hitbox_burst.tscn")
const HITBOX_TOWL = preload("res://nodes/hitboxes/hitbox_towl.tscn")
const HITBOX_EXE = preload("res://nodes/hitboxes/hitbox_execute.tscn")


#############################################################
## Node Ref
#############################################################
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var lp_pos: Marker2D = $HitBoxPos/LpPos
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var hp_bar: ProgressBar = $HpBar
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

## wall bounce helper
var is_touching_wall_left: bool = false
var is_touching_wall_right: bool = false

## hitstun helper
var stun_duration: float = 0


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
	if state in [States.BOUNCE_STUNNED]:
		if is_touching_wall_left:
			_push_direct(Vector2(400, -200))
			is_touching_wall_left = false
			hp_bar.hp_down(1)

			animation_player.stop(true)
			animation_player.play("down")
			state = States.WALL_BOUNCED
			hitlag()
			if get_tree().current_scene.get_node_or_null("Player/Camera"):
				get_tree().current_scene.get_node_or_null("Player/Camera"). \
				start_screen_shake(100, 0.1)
		elif is_touching_wall_right:
			_push_direct(Vector2(-400, -200))
			is_touching_wall_right = false
			hp_bar.hp_down(1)

			animation_player.stop(true)
			animation_player.play("down")
			state = States.WALL_BOUNCED
			hitlag()
			if get_tree().current_scene.get_node_or_null("Player/Camera"):
				get_tree().current_scene.get_node_or_null("Player/Camera"). \
				start_screen_shake(100, 0.1)


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
	_size: Hitbox_size,
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
	) -> void:

	var hitbox: Node2D

	match _size:
		Hitbox_size.MEDIUM:
			hitbox = HITBOX_LP_MEDIUM.instantiate()
		Hitbox_size.LARGE:
			hitbox = HITBOX_LP_LARGE.instantiate()
		Hitbox_size.TOWL:
			hitbox = HITBOX_TOWL.instantiate()
			## Flip towl sprite here so that 
			## it doesn't interfere with others
			if sprite_2d.flip_h: 
				hitbox.scale.x = -1
		Hitbox_size.BURST:
			hitbox = HITBOX_BURST.instantiate()
		Hitbox_size.EXECUTE:
			hitbox = HITBOX_EXE.instantiate()
		_:
			hitbox = HITBOX_LP_MEDIUM.instantiate()

	if sprite_2d.flip_h: ## facing left
		hitbox.position = Vector2(-_pos.x, _pos.y)
	else: ## facing right
		hitbox.position = Vector2(_pos.x, _pos.y)
	
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

	hitbox.time_left_before_queue_free = _time

	add_child(hitbox)


func _set_state(new_state: int) -> void:
	state = States.values()[new_state]


"""
animation_player uses
"""
func _push_x_old(pixel: int) -> void:
	var tween = get_tree().create_tween()
	var new_pos := Vector2.ZERO
	if sprite_2d.flip_h: ## facing left
		new_pos = Vector2(position.x-pixel, position.y)
	else: ## facing left
		new_pos = Vector2(position.x+pixel, position.y)
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


func hitlag(_amount: float = 0.3) -> void:
	if _amount:
		set_physics_process(false)
		await get_tree().create_timer(_amount).timeout
		set_physics_process(true)


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
	_screenshake_amount: Vector2 = Vector2(100, 0.1),
	_damage: int = 1,
	_type: int = 0,
	_zoom: Vector2 = Vector2(0, 0),
	_zoom_duration: float = 0.1
	) -> void:
	if is_in_group("enemy") and _type != Enums.Attack.UNBLOCK and state not in [
		States.HIT_STUNNED,
		States.EXECUTETABLE,
		States.BOUNCE_STUNNED,
		States.ARMOR,
		]:
		if randi_range(0, 1) == 0:
			state = States.BLOCK
			animation_player.stop()
			animation_player.play("blockstunned")
	if state in [States.PARRY, States.PARRY_SUCCESS] and _type == Enums.Attack.NORMAL:
		animation_player.play("parry_success")
		_attacker.hitted(
			self,
			is_face_right,
			Vector2(20, 0),
			0,
			0,
			1,
			Vector2(100, 0.1),
			1,
			Enums.Attack.UNBLOCK
		)
	elif state in [States.BLOCK, States.BLOCK_STUNNED, States.ARMOR] and _type == Enums.Attack.NORMAL:
		if state == States.ARMOR:
			hp_bar.hp_down(_damage)
		else:
			animation_player.stop()
			animation_player.play("blockstunned")
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
		ObjectPooling.spawn_blockSpark_1(position)
	elif state in [States.DODGE, States.DODGE_SUCCESS] and _type != Enums.Attack.THROW:
		if _type == Enums.Attack.UNBLOCK:
			animation_player.play("dodge_success_zoom")
		else:
			animation_player.play("dodge_success")
	elif state in [States.IFRAME, States.EXECUTE]:
		ObjectPooling.spawn_blockSpark_1(position)
	elif _type == Enums.Attack.THROW:
		state = States.THROW_BREAKABLE # Keep this here otherwise throw not work
		animation_player.play("throw_stunned")
	else:
		hp_bar.hp_down(_damage)
		if _attacker.is_in_group("death_zone"):
			animation_player.stop(true)
			animation_player.play("ded")
			stun_duration = hitstun_amount
			state = States.BOUNCE_STUNNED
		elif hp_bar.get_hp() <= 0:
			if push_type in [Enums.Push_types.KNOCKDOWN, Enums.Push_types.EXECUTE]:
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
					stun_duration = hitstun_amount
					state = States.HIT_STUNNED
					animation_player.play("hitted")
				1: ## KNOCKDOWN
					animation_player.stop(true)
					animation_player.play("down")
					stun_duration = hitstun_amount
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
					stun_duration = hitstun_amount

		if is_push_to_the_right:
			_push_direct(push_power)
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
				get_tree().current_scene.get_node_or_null("Player/Camera").zoom(_zoom, _zoom_duration)
			else:
				print_debug("_zoom can't find player/camera")

		ObjectPooling.spawn_hitSpark_1(position)


## This whole thing is to make it easire to adjust attack info ┐(￣～￣)┌ 
## This func is used by attack moves below
func dict_to_spawn_hitbox(info: Dictionary) -> void:
	_spawn_lp_hitbox(
	info.get("size", Hitbox_size.MEDIUM),
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
	info.get("zoom_duration", 0.1)
	)


#############################################################
## Helper
#############################################################
func _remove_collision() -> void:
	if is_instance_valid(collision_shape_2d):
		collision_shape_2d.queue_free()
