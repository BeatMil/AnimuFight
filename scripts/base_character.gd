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
	}


#############################################################
## Preloads
#############################################################
const HITBOX_LP = preload("res://nodes/hitboxes/hitbox_lp.tscn")


#############################################################
## Node Ref
#############################################################
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var lp_pos: Marker2D = $HitBoxPos/LpPos
@onready var sprite_2d: Sprite2D = $Sprite2D


#############################################################
## Config
#############################################################
var state = States.IDLE
var MOVE_SPEED: int = 30000
var MOVE_SPEED_VERT: int = 20000
const FRICTION: float = 0.5


#############################################################
## Private function
#############################################################
func _z_index_equal_to_y() -> void:
	z_index = int(position.y)


func _lerp_velocity_x():
	velocity = velocity.lerp(Vector2(0, velocity.y), FRICTION)


func _lerp_velocity_y():
	velocity = velocity.lerp(Vector2(velocity.x, 0), FRICTION)


func _move_left(delta) ->  void:
	velocity = Vector2(-MOVE_SPEED * delta, velocity.y)
	sprite_2d.flip_h = true


func _move_right(delta) ->  void:
	velocity = Vector2(MOVE_SPEED * delta, velocity.y)
	sprite_2d.flip_h = false


func _move_up(delta) ->  void:
	velocity = Vector2(velocity.x, -MOVE_SPEED_VERT*delta)


func _move_down(delta) ->  void:
	velocity = Vector2(velocity.x, MOVE_SPEED_VERT*delta)


func _lp() ->  void:
	if state == States.LP1:
		animation_player.play("lp2")
		# state = States.LP2
	elif state == States.LP2:
		animation_player.play("lp3")
		# state = States.LP3
	elif state == States.IDLE:
		animation_player.play("lp1")
		# state = States.LP1


func _block() ->  void:
	animation_player.play("block")


"""
animation_player uses
"""
func _spawn_lp_hitbox() -> void:
	var hitbox = HITBOX_LP.instantiate()
	if sprite_2d.flip_h: ## facing left
		hitbox.position = Vector2(-lp_pos.position.x, lp_pos.position.y)
	else: ## facing left
		hitbox.position = Vector2(lp_pos.position.x, lp_pos.position.y)
	add_child(hitbox)


func _set_state(new_state: int) -> void:
	state = States.values()[new_state]


func _push_x(pixel: int) -> void:
	var tween = get_tree().create_tween()
	var new_pos := Vector2.ZERO
	if sprite_2d.flip_h: ## facing left
		new_pos = Vector2(position.x-pixel, position.y)
	else: ## facing left
		new_pos = Vector2(position.x+pixel, position.y)

	tween.tween_property(self, "position", new_pos, 0.2).set_trans(Tween.TRANS_CUBIC)


func _push_x_backward(pixel: int) -> void:
	var tween = get_tree().create_tween()
	var new_pos := Vector2.ZERO
	if sprite_2d.flip_h: ## facing left
		new_pos = Vector2(position.x+pixel, position.y)
	else: ## facing left
		new_pos = Vector2(position.x-pixel, position.y)

	tween.tween_property(self, "position", new_pos, 0.2).set_trans(Tween.TRANS_CUBIC)


#############################################################
## Public functions
#############################################################
"""
hitbox.gd uses this
"""
func hitted(_attacker: CharacterBody2D) -> void:
	if state in [States.PARRY]:
		animation_player.play("parry_success")
		_attacker.hitted(self)
	else:
		animation_player.stop(true)
		animation_player.play("hitted")
		_push_x_backward(100)


#############################################################
## Signals
#############################################################
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass
	if anim_name in ["lp1", "lp2", "lp3", "hitted", "block", "parry_success"]:
		animation_player.play("idle")
		state = States.IDLE
