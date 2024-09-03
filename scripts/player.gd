extends "res://scripts/character_template.gd"


#############################################################
## Built-in
#############################################################
func _ready() -> void:
	pass # Replace with function body.


func _process(_delta: float) -> void:
	pass
	## Debuger
	# debug_label.texat = "PlayerState: %s"%States.keys()[state]


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
## Signals
#############################################################
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass
	if anim_name in ["lp1", "lp2", "lp3"]:
		animation_player.play("idle")
		state = States.IDLE
