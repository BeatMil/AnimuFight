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
	}


#############################################################
## Node Ref
#############################################################
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var lp_pos: Marker2D = $HitBoxPos/LpPos
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var debug_label: Label = $CanvasLayer/DebugLabel


#############################################################
## Preloads
#############################################################
const HITBOX_LP = preload("res://nodes/hitboxes/hitbox_lp.tscn")


#############################################################
## Config
#############################################################
var state = States.IDLE
var MOVE_SPEED: int = 30000
var MOVE_SPEED_VERT: int = 20000
const FRICTION: float = 0.5


#############################################################
## Built-in
#############################################################
func _ready() -> void:
	pass # Replace with function body.


func _process(_delta: float) -> void:
	## Debuger
	debug_label.text = "PlayerState: %s"%States.keys()[state]


func _physics_process(delta: float) -> void:
	if state == States.IDLE:
		# Left/Right movement
		if Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_right"):
			_lerp_velocity_x()
		elif Input.is_action_pressed("ui_left"):
			_move_left(delta)
		elif Input.is_action_pressed("ui_right"):
			_move_right(delta)
		else:
			_lerp_velocity_x()

		# Up/Down movement
		if Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_down"):
			_lerp_velocity_y()
		elif Input.is_action_pressed("ui_up"):
			_move_up(delta)
		elif Input.is_action_pressed("ui_down"):
			_move_down(delta)
		else:
			_lerp_velocity_y()
	else:
		_lerp_velocity_y()
		_lerp_velocity_x()

	move_and_slide()

	_z_index_equal_to_y()


## Godot said this built-in is better for performance (me no understand tho...)
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("lp"):
		_lp()


#############################################################
## Private function
#############################################################
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


func _z_index_equal_to_y() -> void:
	z_index = int(position.y)


#############################################################
## Signals
#############################################################
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass
	if anim_name in ["lp1", "lp2", "lp3"]:
		animation_player.play("idle")
		state = States.IDLE
