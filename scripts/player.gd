extends "res://scripts/base_character.gd"


#############################################################
## Node Ref
#############################################################
@onready var debug_label: Label = $CanvasLayer/DebugLabel


#############################################################
## Config
#############################################################
# var is_face_right:bool = true
var jump_buffer_time = 0.15
var jump_buffer_timer = 0.0


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


## Godot said this built-in is better for performance (me no understand tho...)
func _unhandled_key_input(event: InputEvent) -> void:
	## LP (Light Punch) can also change direction while lping
	if event.is_action_pressed("lp"):
		_lp()

	if Input.is_action_pressed("ui_left"):
		if event.is_action_pressed("lp"):
			sprite_2d.flip_h = true
			_lp()

	if Input.is_action_pressed("ui_right"):
		if event.is_action_pressed("lp"):
			sprite_2d.flip_h = false
			_lp()


	## HP (Heavy Punch)
	if event.is_action_pressed("hp"):
		_hp()

	if Input.is_action_pressed("ui_left"):
		if event.is_action_pressed("hp"):
			sprite_2d.flip_h = true
			_hp()

	if Input.is_action_pressed("ui_right"):
		if event.is_action_pressed("hp"):
			sprite_2d.flip_h = false
			_hp()

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


func _lp() ->  void:
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
		animation_player.play("hp")


#############################################################
## Signals
#############################################################
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass
	if anim_name in ["lp1", "lp2", "lp3", "hitted", "block", "parry_success", "hp"]:
		animation_player.play("idle")
		state = States.IDLE
	if anim_name in ["ded"]:
		queue_free()
