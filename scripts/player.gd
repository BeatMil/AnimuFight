extends "res://scripts/base_character.gd"


#############################################################
## Node Ref
#############################################################
@onready var debug_label: Label = $CanvasLayer/DebugLabel


#############################################################
## Config
#############################################################
# var is_face_right:bool = true


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

	is_face_right = not sprite_2d.flip_h
	_z_index_equal_to_y()


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

	if state in [
		States.IDLE,
		States.PARRY_SUCCESS,
		States.LP1,
		States.LP2,
		States.LP3,
		]:
		## BLOCK
		if event.is_action_pressed("block"):
			_block()

	if state in [States.BLOCK, States.PARRY]:
		if event.is_action_released("block"):
			animation_player.play("idle")
			state = States.IDLE



#############################################################
## Signals
#############################################################
