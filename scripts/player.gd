extends "res://scripts/base_character.gd"


#############################################################
## Node Ref
#############################################################
@onready var debug_label: Label = $CanvasLayer/DebugLabel
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var hit_noise = preload("res://media/sfxs/equip01.wav")


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

var block_buffer_time := 0.2
var block_buffer_timer := 0.0

var body_in_execution_ranges = []

var debug_input_event = null

var can_block_states = [
		States.IDLE,
		States.PARRY_SUCCESS,
		# States.PARRY,
		# States.BLOCK,
		States.LP1,
		States.LP2,
		States.LP3,
		States.HP,
		]

# Hold block input helper
var can_block_states_hold = [
		States.IDLE,
		States.LP1,
		States.LP2,
		States.LP3,
		States.HP,
		]

#############################################################
## Built-in
#############################################################
func _ready() -> void:
	move_speed = 50000
	hp_bar.set_hp(hp)
	print_rich("[img]res://media/sprites/char1/FirstChar_block.png[/img]")
	print_rich("[color=green][b]Nyaaa > w <[/b][/color]")
	pass # Replace with function body.


func _process(_delta: float) -> void:
	debug_label.text = "PlayerState: %s"%States.keys()[state]
	debug_label.text += "\n%s"%input_buffer_timer
	debug_label.text += "\n%s"%block_buffer_timer
	debug_label.text += "\n%s"%Input.is_action_pressed("block")
	debug_label.text += "\n%s"%debug_input_event
	debug_label.text += "\nCameraPos: %s"%$Camera.global_position


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("execute") and \
		state not in [States.EXECUTE, States.HIT_STUNNED, States.BOUNCE_STUNNED]:
		"""
		Find the closest body to player then execute it
		"""
		var closest_range: float
		var closest_body: Object
		for b in body_in_execution_ranges:
			if b.state != States.EXECUTETABLE:
				continue

			var new_dist = position.distance_to(b.position)
			if not closest_range:
				closest_range = new_dist
				closest_body = b
				continue
			
			if new_dist < closest_range:
				closest_range = new_dist
				closest_body = b

		if closest_body:
			execute_carnaging(closest_body.position)
			state = States.ATTACK # order of operation and stuff
			animation_player.play("exe_hadoken")


	## BLOCK
	## DODGE
	if state in can_block_states:
		if Input.is_action_just_pressed("block", true):
			state = States.PARRY
			animation_player.play("block")

		if Input.is_action_just_pressed("dodge"):
			state = States.DODGE
			animation_player.play("dodge")
			# queue_move(_dodge)
	
	if state in [States.PARRY, States.BLOCK]:
		if Input.is_action_pressed("block"):
			if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
				state = States.DODGE
				animation_player.play("dodge")

	debug_input_event = event


func _physics_process(delta: float) -> void:
	_check_wall_bounce()

	if is_on_floor():
		if state == States.AIR:
			animation_player.play("idle")
			state = States.IDLE
	else:
		if state == States.IDLE:
			state = States.AIR
	
	if state == States.AIR:
		# if not animation_player.is_playing():
		# 	animation_player.play("air")
		animation_player.play("jump")
		pass

	# Left/Right movement
	if state in [States.IDLE, States.AIR]:
		if Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_right"):
			_lerp_velocity_x()
		elif Input.is_action_pressed("ui_left"):
			_move_left(delta)
		elif Input.is_action_pressed("ui_right"):
			_move_right(delta)
		else:
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
	
	## Animation Section
	# Walking animation
	if state in [States.IDLE]:
		if Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_right"):
			animation_player.play("idle")
		elif Input.is_action_pressed("ui_left"):
			animation_player.play("walk")
		elif Input.is_action_pressed("ui_right"):
			animation_player.play("walk")
		else:
			animation_player.play("idle")

	_gravity(delta)
	move_and_slide()

	is_face_right = not sprite_2d.flip_h
	# _z_index_equal_to_y()

	## Hitstun
	## Keep the stun duration while in air
	## start stun duration when on floor
	if stun_duration > 0 and \
		state in [
		States.HIT_STUNNED,
		States.WALL_BOUNCED,
		States.BOUNCE_STUNNED,
		States.BLOCK_STUNNED
		] and is_on_floor():
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

	if Input.is_action_just_pressed("lp"):
		queue_move(_lp)


	if Input.is_action_just_pressed("hp"):
		queue_move(_hp)

	if input_buffer_timer > 0:
		input_buffer_timer -= delta

	## Block buffer
	_check_block_buffer(delta)

	if state in [States.THROW_BREAKABLE]:
		if Input.is_action_just_pressed("hp"):
			# Throw break
			animation_player.play("burst")
			next_move = null

	if state in [States.BLOCK, States.PARRY]:
		if Input.is_action_just_released("block"):
			_add_block_buffer_time()

	## BLOCK
	## Must check every frame, can't put in _input cause it only check when press and release
	if state in can_block_states_hold:
		if Input.is_action_pressed("block"):
			state = States.PARRY
			animation_player.play("block")


#############################################################
## Public function
#############################################################
func set_camera(value: bool):
	$Camera.get_node("Camera2D").enabled = value


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


func _check_block_buffer(delta) -> void:
	if block_buffer_timer > 0 and state in [States.BLOCK, States.PARRY] :
		block_buffer_timer -= delta
	elif block_buffer_timer < 0 and state in [States.BLOCK, States.PARRY] :
		animation_player.play("idle")
		block_buffer_timer = 0
	

func play_hit_random_pitch():
	audio_stream_player.stream = hit_noise
	audio_stream_player.pitch_scale = randf_range(0.8, 1.2)
	audio_stream_player.play()


#############################################################
## Fix stuck in blocking
#############################################################
func _add_block_buffer_time() -> void:
	block_buffer_timer = block_buffer_time


#############################################################
## Attack info
#############################################################
func _lp() ->  void:
	if Input.is_action_pressed("ui_left"):
		sprite_2d.flip_h = true

	if Input.is_action_pressed("ui_right"):
		sprite_2d.flip_h = false

	if state == States.LP1:
		animation_player.play("lp2")
	elif state == States.LP2:
		animation_player.play("lp3")
	elif state in [States.IDLE, States.PARRY_SUCCESS, States.DODGE_SUCCESS]: ## <<-- start with this one
		animation_player.play("lp1")

func lp1_info() -> void:
	var info = {
	"size": Hitbox_size.MEDIUM,
	"time": 0.1,
	"push_power_ground": Vector2(50, 0),
	"push_type_ground": Enums.Push_types.NORMAL,
	"push_power_air": Vector2(100, -150),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0,
	"hitstun_amount_ground": 0.5,
	"hitlag_amount_air": 0,
	"hitstun_amount_air": 0.5,
	"screenshake_amount": Vector2(0, 0),
	"damage": 1,
	"type": Enums.Attack.NORMAL,
	}
	dict_to_spawn_hitbox(info)
func lp2_info() -> void:
	var info = {
	"size": Hitbox_size.MEDIUM,
	"time": 0.1,
	"push_power_ground": Vector2(50, 0),
	"push_type_ground": Enums.Push_types.NORMAL,
	"push_power_air": Vector2(100, -150),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0,
	"hitstun_amount_ground": 0.5,
	"hitlag_amount_air": 0,
	"hitstun_amount_air": 0.5,
	"screenshake_amount": Vector2(0, 0),
	"damage": 1,
	"type": Enums.Attack.NORMAL,
	}
	dict_to_spawn_hitbox(info)
func lp3_info() -> void:
	var info = {
	"size": Hitbox_size.MEDIUM,
	"time": 0.1,
	"push_power_ground": Vector2(800, -100),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(100, -150),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0.2,
	"hitstun_amount_ground": 0.7,
	"hitlag_amount_air": 0,
	"hitstun_amount_air": 0.7,
	"screenshake_amount": Vector2(10, 0.1),
	"damage": 2,
	"type": Enums.Attack.NORMAL,
	"zoom": Vector2(0.1, 0.1),
	}
	dict_to_spawn_hitbox(info)


func _hp() ->  void:
	if state in [
		States.IDLE,
		States.PARRY_SUCCESS,
		States.LP1,
		States.LP2,
		States.LP3,
		States.DODGE_SUCCESS
		]:
		if Input.is_action_pressed("ui_left"):
			sprite_2d.flip_h = true

		if Input.is_action_pressed("ui_right"):
			sprite_2d.flip_h = false

		if Input.is_action_pressed("ui_down"):
			animation_player.play("down_hp")
		else:
			animation_player.play("hp")

func hp_info() ->  void:
	var info = {
	"size": Hitbox_size.MEDIUM,
	"time": 0.1,
	"push_power_ground": Vector2(1200, 0),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(1200, 0),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0.3,
	"hitstun_amount_ground": 1,
	"hitlag_amount_air": 0.2,
	"hitstun_amount_air": 1,
	"screenshake_amount": Vector2(10, 0.2),
	"damage": 3,
	"type": Enums.Attack.NORMAL,
	# "zoom": Vector2(1, 1),
	}
	dict_to_spawn_hitbox(info)
func down_hp_info() ->  void:
	var info = {
	"size": Hitbox_size.LARGE,
	"time": 0.1,
	"push_power_ground": Vector2(0, -200),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(0, -200),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0.1,
	"hitstun_amount_ground": 1,
	"hitlag_amount_air": 0.0,
	"hitstun_amount_air": 1,
	"screenshake_amount": Vector2(10, 0.1),
	"damage": 2,
	"type": Enums.Attack.NORMAL,
	"pos": $HitBoxPos/DownHpPos.position,
	# "zoom": Vector2(1, 1),
	}
	dict_to_spawn_hitbox(info)
func burst_info() ->  void:
	var info = {
	"size": Hitbox_size.BURST,
	"time": 0.1,
	"push_power_ground": Vector2(0, -200),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(0, -200),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0.1,
	"hitstun_amount_ground": 1,
	"hitlag_amount_air": 0.0,
	"hitstun_amount_air": 1,
	"screenshake_amount": Vector2(10, 0.1),
	"damage": 2,
	"type": Enums.Attack.NORMAL,
	"pos": $HitBoxPos/BurstPos.position,
	"zoom": Vector2(0.1, 0.1),
	"zoom_duration": 0.05,
	}
	dict_to_spawn_hitbox(info)



func _down_hp() ->  void:
	if state in [States.IDLE, States.PARRY_SUCCESS, States.LP1, States.LP2, States.LP3,]:
		if Input.is_action_pressed("ui_left"):
			sprite_2d.flip_h = true

		if Input.is_action_pressed("ui_right"):
			sprite_2d.flip_h = false

		animation_player.play("down_hp")


#############################################################
## Defense
#############################################################
func _dodge() -> void:
	animation_player.play("dodge")



#############################################################
## Get thrown
#############################################################
func _get_thrown_by_towl() -> void:
	hitted(
		self,
		$Sprite2D.flip_h,
		Vector2(400, -300),
		1,
		0,
		0.1,
		Vector2(10, 0.2),
		3,
		0,
	)

#############################################################
## Helper
#############################################################
func _zoom() -> void:
	$Camera.zoom(Vector2(0.2, 0.2), 0.3)


func _hitbox_exe_hadoken() -> void:
	var hadoken = HITBOX_EXE.instantiate()
	hadoken.position = lp_pos.position
	add_child(hadoken)


func exe_hadoken_info() ->  void:
	var info = {
	"size": Hitbox_size.EXECUTE,
	"time": 0.1,
	"push_power_ground": Vector2(1200, -200),
	"push_type_ground": Enums.Push_types.EXECUTE,
	"push_power_air": Vector2(1200, -200),
	"push_type_air": Enums.Push_types.EXECUTE,
	"hitlag_amount_ground": 0.5,
	"hitstun_amount_ground": 1,
	"hitlag_amount_air": 1,
	"hitstun_amount_air": 1,
	"screenshake_amount": Vector2(20, 0.4),
	"damage": 2,
	"type": Enums.Attack.NORMAL,
	"pos": $HitBoxPos/DownHpPos.position,
	"zoom": Vector2(0.3, 0.3),
	"zoom_duration": 0.5,
	}
	dict_to_spawn_hitbox(info)

func execute_carnaging(pos: Vector2) -> void:
	# choose to go through enemy or not
	if Input.is_action_pressed("ui_left"):
		sprite_2d.flip_h = true

	if Input.is_action_pressed("ui_right"):
		sprite_2d.flip_h = false

	var offset = Vector2(180, 0)
	if not sprite_2d.flip_h:
		offset.x *= -1
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", pos+offset, 0.2).set_trans(Tween.TRANS_CUBIC)


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
		"burst",
		"hp",
		"down_hp",
		]:
		animation_player.play("idle")
	if anim_name in ["ded", "execute"]:
		queue_free()


func _on_execute_area_r_body_entered(body: Node2D) -> void:
	body_in_execution_ranges.append(body)


func _on_execute_area_r_body_exited(body: Node2D) -> void:
	body_in_execution_ranges.erase(body)
