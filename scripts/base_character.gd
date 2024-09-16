extends CharacterBody2D


"""
Check flip_h for which direction character is facing
flip_h == true;  facing left
flip_h == false; facing right
"""

# Beat's own state machine XD
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
	}


enum Hitbox_size {
	SMALL,
	MEDIUM,
	LARGE,
	}


#############################################################
## Preloads
#############################################################
const HITBOX_LP = preload("res://nodes/hitboxes/hitbox_lp.tscn")
const HITBOX_LP2 = preload("res://nodes/hitboxes/hitbox_lp2.tscn")


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
var hp: int = 5
const FRICTION: float = 0.5


#############################################################
## Built-in
#############################################################
func _ready() -> void:
	hp_bar.set_hp(hp)


### Seems like it doesn't run the process functions when used as inheritance
func _physics_process(_delta: float) -> void:
	pass


#############################################################
## Private function
#############################################################
func _z_index_equal_to_y() -> void:
	z_index = int(position.y)


func _lerp_velocity_x():
	velocity = velocity.lerp(Vector2(0, velocity.y), FRICTION)


func _lerp_velocity_y():
	velocity = velocity.lerp(Vector2(velocity.x, 0), FRICTION)


func _gravity(delta):
	if not is_on_floor():
		velocity += Vector2(0, gravity_power*delta)


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
func _spawn_lp_hitbox(_size: Hitbox_size, _time: float = 0.1, _push_power: int = 20,
	_push_type: Enums.Push_types = Enums.Push_types.NORMAL) -> void:

	var hitbox: Node2D

	if _size == Hitbox_size.MEDIUM:
		hitbox = HITBOX_LP.instantiate()
	elif _size == Hitbox_size.LARGE:
		hitbox = HITBOX_LP2.instantiate()

	if sprite_2d.flip_h: ## facing left
		hitbox.position = Vector2(-lp_pos.position.x, lp_pos.position.y)
	else: ## facing left
		hitbox.position = Vector2(lp_pos.position.x, lp_pos.position.y)
	
	## Set hitbox collision target
	if self.is_in_group("player"):
		hitbox.is_hit_enemy = true
	elif self.is_in_group("enemy"):
		hitbox.is_hit_player = true
	
	## Set push_type
	hitbox.push_type = _push_type

	hitbox.time_left_before_queue_free = _time
	hitbox.push_power = _push_power

	add_child(hitbox)


func _set_state(new_state: int) -> void:
	state = States.values()[new_state]


"""
animation_player uses
"""
func _push_x(pixel: int) -> void:
	var tween = get_tree().create_tween()
	var new_pos := Vector2.ZERO
	if sprite_2d.flip_h: ## facing left
		new_pos = Vector2(position.x-pixel, position.y)
	else: ## facing left
		new_pos = Vector2(position.x+pixel, position.y)

	tween.tween_property(self, "position", new_pos, 0.2).set_trans(Tween.TRANS_CUBIC)


func _push_x_direct(pixel: int) -> void:
	var tween = get_tree().create_tween()
	var new_pos := Vector2.ZERO
	new_pos = Vector2(position.x+pixel, position.y)
	tween.tween_property(self, "position", new_pos, 0.2).set_trans(Tween.TRANS_CUBIC)


#############################################################
## Public functions
#############################################################
"""
hitbox.gd uses this
"""
func hitted(_attacker: CharacterBody2D, is_push_to_the_right: bool, push_power: int = 20, push_type: int = 0) -> void:
	if state in [States.PARRY, States.PARRY_SUCCESS]:
		animation_player.play("parry_success")
		_attacker.hitted(self, is_face_right)
	else:
		hp_bar.hp_down(1)
		if hp_bar.get_hp() <= 0:
			state = States.HIT_STUNNED
			animation_player.stop(true)
			animation_player.play("ded")
			collision_shape_2d.queue_free()
		else:
			match push_type:
				0: ## NORMAL
					animation_player.stop(true)
					animation_player.play("hitted")
				1: ## KNOCKDOWN
					animation_player.stop(true)
					animation_player.play("down")
				_:
					animation_player.stop(true)
					animation_player.play("hitted")
		if is_push_to_the_right:
			_push_x_direct(push_power)
		else:
			_push_x_direct(-push_power)
