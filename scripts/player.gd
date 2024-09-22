extends "res://scripts/base_character.gd"


#############################################################
## Node Ref
#############################################################
@onready var debug_label: Label = $CanvasLayer/DebugLabel


#############################################################
## Config
#############################################################
# var is_face_right:bool = true
var jump_buffer_time := 0.15
var jump_buffer_timer := 0.0


var input_buffer_time := 0.2
var input_buffer_timer := 0.0
var is_performing_move: bool = false
var next_move = null


#############################################################
## Built-in
#############################################################
func _ready() -> void:
	print_rich("[img]res://media/sprites/char1/FirstChar_block.png[/img]")
	print_rich("[color=green][b]Nyaaa > w <[/b][/color]")
	pass # Replace with function body.


func _process(_delta: float) -> void:
	# Debuger
	debug_label.text = "PlayerState: %s"%States.keys()[state]
	debug_label.text += "\n%s"%input_buffer_timer


func _physics_process(delta: float) -> void:
	## Check is_on_floor
	if is_on_floor():
		if state == States.AIR:
			state = States.IDLE
			# if not animation_player.is_playing():
			animation_player.play("idle")
	else:
		if state == States.IDLE:
			state = States.AIR
	
	if state == States.AIR:
		if not animation_player.is_playing():
			animation_player.play("air")

	if state in [States.IDLE, States.AIR]:

		# Left/Right movement
		if Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_right"):
			_lerp_velocity_x()
		elif Input.is_action_pressed("ui_left"):
			_move_left(delta)
		elif Input.is_action_pressed("ui_right"):
			_move_right(delta)
		else:
			pass
			friction = 0.5
			_lerp_velocity_x()

		# Jump buffer
		if Input.is_action_just_pressed("jump"):
			jump_buffer_timer = jump_buffer_time
		elif jump_buffer_timer > 0:
			jump_buffer_timer -= delta

		if jump_buffer_timer > 0:
			_jump(delta)
	else:
		## Adding friction like this is not gonna go well (っ˘̩╭╮˘̩)っ 
		friction = 0.1
		_lerp_velocity_x()

	_gravity(delta)
	move_and_slide()

	is_face_right = not sprite_2d.flip_h
	# _z_index_equal_to_y()

	## hitstun...
	if stun_duration > 0 and state in [States.HIT_STUNNED, States.WALL_BOUNCED, States.BOUNCE_STUNNED]:
		## remain in stun state
		stun_duration -= delta
	elif stun_duration < 0:
		# state = States.IDLE
		animation_player.play("idle")
		stun_duration = 0

	##################
	## Input buffer
	##################
	if next_move and input_buffer_timer > 0 and state not in [States.ATTACK, States.HP]:
		next_move.call()
		next_move = null
		input_buffer_timer = 0
		print_rich("[color=brown][b]Nyaaa > w <[/b][/color]")

	if Input.is_action_just_pressed("lp"):
		queue_move(_lp)


	if Input.is_action_just_pressed("hp"):
		queue_move(_hp)

	if input_buffer_timer > 0:
		input_buffer_timer -= delta


## Godot said this built-in is better for performance (me no understand tho...)
func _unhandled_key_input(event: InputEvent) -> void:
	## BLOCK
	if state in [
		States.IDLE,
		States.PARRY_SUCCESS,
		States.LP1,
		States.LP2,
		States.LP3,
		]:
		if event.is_action_pressed("block"):
			_block()

	if state in [States.BLOCK, States.PARRY]:
		if event.is_action_released("block"):
			animation_player.play("idle")
			state = States.IDLE


#############################################################
## Private function
#############################################################
func handle_jump_buffer(delta):
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	elif jump_buffer_timer > 0:
		jump_buffer_timer -= delta


func queue_move(the_move) -> void:
	next_move = the_move
	input_buffer_timer = input_buffer_time


func _lp() ->  void:
	if Input.is_action_pressed("ui_left"):
		sprite_2d.flip_h = true

	if Input.is_action_pressed("ui_right"):
		sprite_2d.flip_h = false

	if state == States.LP1:
		animation_player.play("lp2")
		# state = States.LP2
	elif state == States.LP2:
		animation_player.play("lp3")
		# state = States.LP3
	elif state in [States.IDLE, States.PARRY_SUCCESS]: ## <<-- start with this one
		animation_player.play("lp1")
		# state = States.LP1


func _hp() ->  void:
	if state in [States.IDLE, States.PARRY_SUCCESS, States.LP1, States.LP2, States.LP3,]:
		if Input.is_action_pressed("ui_left"):
			sprite_2d.flip_h = true

		if Input.is_action_pressed("ui_right"):
			sprite_2d.flip_h = false

		if Input.is_action_pressed("ui_down"):
			animation_player.play("down_hp")
		else:
			animation_player.play("hp")



func _down_hp() ->  void:
	if state in [States.IDLE, States.PARRY_SUCCESS, States.LP1, States.LP2, States.LP3,]:
		if Input.is_action_pressed("ui_left"):
			sprite_2d.flip_h = true

		if Input.is_action_pressed("ui_right"):
			sprite_2d.flip_h = false

		animation_player.play("down_hp")


#############################################################
## Signals
#############################################################
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass
	if anim_name in [
		"lp1",
		"lp2",
		"lp3",
		"block",
		"parry_success",
		"hp",
		"down_hp",
		]:
		animation_player.play("idle")
		state = States.IDLE
	if anim_name in ["ded"]:
		queue_free()
