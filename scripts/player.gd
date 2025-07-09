extends "res://scripts/base_character.gd"


#############################################################
## Node Ref
#############################################################
@onready var debug_label: Label = $CanvasLayer/DebugLabel
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var hit_noise = preload("res://media/sfxs/gc_punch_whiff.wav")
@onready var air_throw_pos_r: Marker2D = $HitBoxPos/AirThrowPosR
@onready var air_throw_pos_l: Marker2D = $HitBoxPos/AirThrowPosL
@onready var grab_pos_r: Marker2D = $HitBoxPos/GrabPosR
@onready var grab_pos_l: Marker2D = $HitBoxPos/GrabPosL
@onready var hp_bar_2: TextureProgressBar = $CanvasLayer/HpBar2
@onready var profile_player: AnimationPlayer = $CanvasLayer/Profile/AnimationPlayer


#############################################################
## Config
#############################################################
# var is_face_right:bool = true
var jump_buffer_time := 0.15
var jump_buffer_timer := 0.0

var tech_roll_time := 0.2
var tech_roll_timer := 0.0

var input_buffer_time := 0.1
var input_buffer_timer := 0.0
var is_performing_move: bool = false
var next_move = null

var block_buffer_time := 0.2
var block_buffer_timer := 0.0

var body_in_execution_ranges = []
var grabbed_enemy: Object

var debug_input_event = null

var can_block_states = [
		States.IDLE,
		States.PARRY_SUCCESS,
		States.DODGE_SUCCESS,
		States.LP1,
		States.LP2,
		States.LP3,
		States.HP,
		States.EXECUTE,
		]

# Hold block input helper
var can_block_states_hold = [
		States.IDLE,
		States.LP1,
		States.LP2,
		States.LP3,
		States.HP,
		]

# var input_history := ["right","left","n","right","right","n","n","n","n","right"]
# var input_history := ["right","left","n","right","right","n","n","n","n","right","left"]
# var input_history := ["n","n","n","n","right","right","right","right","right"]
# var input_history := ["n","right","n","n","n","n","right","right","right","right","right"]
var input_history := []

#############################################################
## Built-in
#############################################################
func _ready() -> void:
	move_speed = 50000
	hp_bar = hp_bar_2
	hp_bar.set_hp(hp)
	hp_bar.hp_down_sig.connect(_play_profile_hitted)
	hp_bar.hp_out.connect(_on_hp_out)
	print_rich("[img]res://media/sprites/char1/FirstChar_block.png[/img]")
	print_rich("[color=green][b]Nyaaa > w <[/b][/color]")
	$ExecuteShow.queue_free()
	pass # Replace with function body.

	# _check_input_history()


func _process(_delta: float) -> void:
	if OS.is_debug_build():
		debug_label.text = "PlayerState: %s"%States.keys()[state]
		debug_label.text += "\n%0.3f"%input_buffer_timer
		debug_label.text += "\n%0.3f"%block_buffer_timer
		debug_label.text += "\n%0.3f"%AttackQueue.attack_queue_timer.time_left
		debug_label.text += "\n%0.3f"%tech_roll_timer
		debug_label.text += "\n%s"%animation_player.current_animation
		# debug_label.text += "\n%s"%[input_history]
		# debug_label.text += "\nGoh"
		# debug_label.text += "\n%s"%Input.is_action_pressed("block")
		# debug_label.text += "\n%s"%debug_input_event
		# debug_label.text += "\n%s"%next_move
		# debug_label.text += "\nCameraPos: %s"%$Camera.global_position


func _input(event: InputEvent) -> void:
	if is_ded:
		return

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
	# if state in can_block_states:
	if state not in [States.BOUNCE_STUNNED, States.WALL_BOUNCED, States.IFRAME, States.AIR_SPD]:
		if Input.is_action_just_pressed("block", true) and state == States.HIT_STUNNED:
			animation_player.play("late_parry")
			hp_bar.hp_up_late_parry()
		elif Input.is_action_just_pressed("block", true):
			state = States.PARRY
			animation_player.play("block")

		if Input.is_action_just_pressed("dodge"):
			state = States.DODGE
			animation_player.play("dodge")
	
	## DODGE
	if state in [States.PARRY, States.BLOCK]:
		if Input.is_action_pressed("block"):
			if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right") or\
				Input.is_action_just_pressed("dodge"):
				state = States.DODGE
				animation_player.play("dodge")
		elif Input.is_action_just_released("block"):
			_add_block_buffer_time()

	# debug_input_event = event


func _physics_process(delta: float) -> void:
	if is_ded:
		return
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
		if Input.is_action_pressed("left") and Input.is_action_pressed("right"):
			_lerp_velocity_x()
		elif Input.is_action_pressed("left"):
			_move_left(delta)
		elif Input.is_action_pressed("right"):
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
	
	# Tech roll
	if state in [States.BOUNCE_STUNNED, States.WALL_BOUNCED]:
		if is_on_floor():
			tech_roll_timer -= delta
		else:
			tech_roll_timer = tech_roll_time
	
	if (Input.is_action_just_pressed("down") or Input.is_action_just_pressed("block")) \
		and state in [States.BOUNCE_STUNNED, States.WALL_BOUNCED] and is_on_floor() and tech_roll_timer > 0:
		animation_player.play("techroll")
		hp_bar.hp_up_late_parry()
	
	
	## Animation Section
	# Walking animation
	if state in [States.IDLE]:
		if Input.is_action_pressed("left") and Input.is_action_pressed("right"):
			animation_player.play("idle")
		elif Input.is_action_pressed("left"):
			animation_player.play("walk")
		elif Input.is_action_pressed("right"):
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
	if next_move and input_buffer_timer > 0 and state not in [States.ATTACK]:
		next_move.call()
		next_move = null
		input_buffer_timer = 0
	elif input_buffer_timer > 0:
		input_buffer_timer -= delta

	if Input.is_action_pressed("lp") and Input.is_action_pressed("hp"):
		_lp_hp()

	if Input.is_action_just_pressed("lp"):
		queue_move(_lp)

	if Input.is_action_just_pressed("hp"):
		queue_move(_hp)

	if Input.is_action_just_pressed("grab"):
		queue_move(_grab)

	_check_input_history()

	##################
	## Block buffer
	##################
	_check_block_buffer(delta)

	if state in [States.THROW_BREAKABLE]:
		if Input.is_action_just_pressed("hp"):
			# Throw break
			animation_player.play("burst")
			next_move = null

	## BLOCK
	## Must check every frame, can't put in _input cause it only check when press and release
	if state in can_block_states_hold:
		if Input.is_action_pressed("block"):
			state = States.PARRY
			animation_player.play("block")
	
	## Air SPD burst
	if is_on_floor() and state == States.AIR_SPD:
		# state = States.ATTACK
		animation_player.play("air_spd_burst")

		# spawn hitbox



#############################################################
## Public function
#############################################################
func set_camera(value: bool):
	$Camera.get_node("Camera2D").enabled = value


func set_grabbed_enemy(enemy: Object) -> void:
	grabbed_enemy = enemy


func give_air_throw_pos() -> Marker2D:
	if sprite_2d.flip_h:
		return air_throw_pos_l
	else:
		return air_throw_pos_r


func give_wall_throw_pos() -> Marker2D:
	if sprite_2d.flip_h:
		return grab_pos_l
	else:
		return grab_pos_r


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


func _check_input_history() -> void:
	if Input.is_action_pressed("left") and Input.is_action_pressed("right"):
		input_history.append("n")
	elif Input.is_action_pressed("left"):
		input_history.append("left")
	elif Input.is_action_pressed("right"):
		input_history.append("right")
	elif Input.is_action_pressed("block"):
		input_history.append("block")
	else:
		input_history.append("n")
	if len(input_history) > 15:
		input_history.pop_front()
		
	var dash_right = Command.new(["right","n","right"])
	var dash_left = Command.new(["left","n","left"])
	for i in range(len(input_history)-1, -1, -1):
		dash_right.calculate(input_history[i])
		dash_left.calculate(input_history[i])
	if dash_right.get_command_complete(): 
		queue_move(_dash_right)
		print("_dash_right")
		input_history.clear()
	if dash_left.get_command_complete():
		queue_move(_dash_left)
		input_history.clear()


func _play_profile_hitted() -> void:
	profile_player.play("hitted")


#############################################################
## Fix stuck in blocking
#############################################################
func _add_block_buffer_time() -> void:
	block_buffer_timer = block_buffer_time


#############################################################
## Command list?
#############################################################
var cant_dash_state = [
	States.HIT_STUNNED,
	States.BOUNCE_STUNNED,
	States.WALL_BOUNCED,
	States.GRABBED,
	States.IFRAME,
	States.AIR_SPD,
	]

func _dash_left() -> void:
	if state in cant_dash_state:
		return
	sprite_2d.flip_h = true
	animation_player.play("dash")


func _dash_right() -> void:
	if state in cant_dash_state:
		return
	sprite_2d.flip_h = false
	animation_player.play("dash")


#############################################################
## Attack info
#############################################################
func _lp() ->  void:
	if state not in [
		States.IDLE,
		States.DASH,
		States.PARRY_SUCCESS,
		States.DODGE_SUCCESS,
		States.LP1,
		States.LP2,
		States.JF_SHOULDER,
	]:
		return

	if Input.is_action_pressed("left"):
		sprite_2d.flip_h = true

	if Input.is_action_pressed("right"):
		sprite_2d.flip_h = false

	if state == States.JF_SHOULDER:
		animation_player.play("hp")
	elif state == States.LP1:
		animation_player.play("lp2")
	elif state == States.LP2:
		animation_player.play("lp3")
	else: ## <<-- start with this one
		animation_player.play("lp1")

func lp1_info() -> void:
	var info = {
	"size": Hitbox_type.MEDIUM,
	"time": 0.1,
	"push_power_ground": Vector2(50, 0),
	"push_type_ground": Enums.Push_types.NORMAL,
	"push_power_air": Vector2(200, -50),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0,
	"hitstun_amount_ground": 0.5,
	"hitlag_amount_air": 0,
	"hitstun_amount_air": 0.1,
	"screenshake_amount": Vector2(0, 0),
	"damage": 1,
	"type": Enums.Attack.NORMAL,
	"pos": $HitBoxPos/LpPos.position,
	}
	dict_to_spawn_hitbox(info)
func lp2_info() -> void:
	var info = {
	"size": Hitbox_type.MEDIUM,
	"time": 0.1,
	"push_power_ground": Vector2(50, 0),
	"push_type_ground": Enums.Push_types.NORMAL,
	"push_power_air": Vector2(200, -50),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0,
	"hitstun_amount_ground": 0.5,
	"hitlag_amount_air": 0,
	"hitstun_amount_air": 0.1,
	"screenshake_amount": Vector2(0, 0),
	"damage": 1,
	"type": Enums.Attack.NORMAL,
	"pos": $HitBoxPos/LpPos.position,
	}
	dict_to_spawn_hitbox(info)
func lp3_info() -> void:
	var info = {
	"size": Hitbox_type.MEDIUM,
	"time": 0.1,
	"push_power_ground": Vector2(200, -100),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(300, -100),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0.2,
	"hitstun_amount_ground": 1.0,
	"hitlag_amount_air": 0.2,
	"hitstun_amount_air": 1.0,
	"screenshake_amount": Vector2(10, 0.1),
	"damage": 2,
	"type": Enums.Attack.NORMAL,
	"zoom": Vector2(0.05, 0.05),
	}
	dict_to_spawn_hitbox(info)
func lp4_info() -> void:
	var info = {
	"size": Hitbox_type.MEDIUM,
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


func _hp() ->  void:
	if state not in [
		States.IDLE,
		States.DASH,
		States.PARRY_SUCCESS,
		States.DODGE_SUCCESS,
		States.LP1,
		States.LP2,
		States.LP3,
		]: ## <<-- start with this one
		return

	if Input.is_action_pressed("left"):
		sprite_2d.flip_h = true

	if Input.is_action_pressed("right"):
		sprite_2d.flip_h = false

	if Input.is_action_pressed("down"):
		animation_player.play("down_hp")
	elif Input.is_action_pressed("up"):
		animation_player.play("air_throw")
	else:
		animation_player.play("hp")
	# if state == States.TA:
	# 	animation_player.play("spell")
	# elif state == States.SPELL:
	# 	animation_player.play("tan")
	# elif Input.is_action_pressed("ui_down"):
	# 	animation_player.play("down_hp")
	# elif state in [States.IDLE, States.PARRY_SUCCESS, States.DODGE_SUCCESS]: ## <<-- start with this one
	# 	animation_player.play("ta")

func hp_info() ->  void:
	var info = {
	"size": Hitbox_type.MEDIUM,
	"time": 0.1,
	"push_power_ground": Vector2(1200, -100),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(1200, -100),
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
func burst_info() ->  void:
	var info = {
	"size": Hitbox_type.BURST,
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
	"type": Enums.Attack.UNBLOCK,
	"pos": $HitBoxPos/BurstPos.position,
	"zoom": Vector2(0.1, 0.1),
	"zoom_duration": 0.05,
	}
	dict_to_spawn_hitbox(info)
func ta_info() -> void:
	var info = {
	"size": Hitbox_type.MEDIUM,
	"time": 0.1,
	"push_power_ground": Vector2(0, 0),
	"push_type_ground": Enums.Push_types.NORMAL,
	"push_power_air": Vector2(0, 0),
	"push_type_air": Enums.Push_types.NORMAL,
	"hitlag_amount_ground": 0.1,
	"hitstun_amount_ground": 1.5,
	"hitlag_amount_air": 0.1,
	"hitstun_amount_air": 1.5,
	"screenshake_amount": Vector2(10, 0.1),
	"damage": 3,
	"type": Enums.Attack.NORMAL,
	}
	dict_to_spawn_hitbox(info)
func tan_info() -> void:
	var info = {
	"size": Hitbox_type.MEDIUM,
	"time": 0.1,
	"push_power_ground": Vector2(300, -250),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(50, -300),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0.5,
	"hitstun_amount_ground": 2,
	"hitlag_amount_air": 0.5,
	"hitstun_amount_air": 2,
	"screenshake_amount": Vector2(10, 0.2),
	"damage": 5,
	"type": Enums.Attack.NORMAL,
	"zoom": Vector2(0.2, 0.2),
	}
	dict_to_spawn_hitbox(info)
func abel_throw_info() -> void:
	var info = {
	"size": Hitbox_type.MEDIUM,
	"time": 0.1,
	"push_power_ground": Vector2(100, -100),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(100, -100),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0.5,
	"hitstun_amount_ground": 2,
	"hitlag_amount_air": 0.5,
	"hitstun_amount_air": 2,
	"screenshake_amount": Vector2(10, 0.2),
	"damage": 0,
	"type": Enums.Attack.P_THROW,
	"zoom": Vector2(0.2, 0.2),
	}
	dict_to_spawn_hitbox(info)
func air_throw_info() ->  void:
	var info = {
	"size": Hitbox_type.AIR_THROW,
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
	"damage": 0,
	"type": Enums.Attack.P_AIR_THROW,
	}
	dict_to_spawn_hitbox(info)
func spd_burst_info() ->  void:
	var info = {
	"size": Hitbox_type.BOUND,
	"time": 0.1,
	"push_power_ground": Vector2(0, -200),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(0, -200),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0.1,
	"hitstun_amount_ground": 0.1,
	"hitlag_amount_air": 0.0,
	"hitstun_amount_air": 0.1,
	"screenshake_amount": Vector2(10, 0.1),
	"damage": 5,
	"type": Enums.Attack.NORMAL,
	"pos": $HitBoxPos/BurstPos.position,
	"zoom": Vector2(0.1, 0.1),
	"zoom_duration": 0.05,
	}
	dict_to_spawn_hitbox(info)


func _lp_hp() ->  void:
	if state not in [
		States.IDLE,
		States.ATTACK,
		States.DASH,
		States.PARRY_SUCCESS,
		States.DODGE_SUCCESS,
		States.LP1,
		States.LP2,
		States.LP3,
		]: ## <<-- start with this one
		return

	if Input.is_action_pressed("left"):
		sprite_2d.flip_h = true

	if Input.is_action_pressed("right"):
		sprite_2d.flip_h = false

	if Input.is_action_pressed("down"):
		animation_player.play("ground_grab")
	else:
		animation_player.play("forward_hp")


func down_hp_info() ->  void:
	var info = {
	"size": Hitbox_type.LARGE,
	"time": 0.1,
	"push_power_ground": Vector2(100, -200),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(100, -50),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0.1,
	"hitstun_amount_ground": 0.1,
	"hitlag_amount_air": 0.0,
	"hitstun_amount_air": 0.1,
	"screenshake_amount": Vector2(10, 0.1),
	"damage": 2,
	"type": Enums.Attack.NORMAL,
	"pos": $HitBoxPos/DownHpPos.position,
	# "zoom": Vector2(1, 1),
	}
	dict_to_spawn_hitbox(info)
func forward_hp_info() ->  void:
	var info = {
	"size": Hitbox_type.MEDIUM,
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
func wall_throw_info() ->  void:
	var info = {
	"size": Hitbox_type.LARGE,
	"time": 0.1,
	"push_power_ground": Vector2(100, 0),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(100, 0),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0.3,
	"hitstun_amount_ground": 1,
	"hitlag_amount_air": 0.2,
	"hitstun_amount_air": 1,
	"screenshake_amount": Vector2(10, 0.2),
	"damage": 0,
	"type": Enums.Attack.P_WALL_THROW,
	}
	dict_to_spawn_hitbox(info)
func ground_throw_info() ->  void:
	var info = {
	"size": Hitbox_type.GROUND_THROW,
	"time": 0.5,
	"push_power_ground": Vector2(100, 0),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(100, 0),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0.3,
	"hitstun_amount_ground": 0.2,
	"hitlag_amount_air": 0.2,
	"hitstun_amount_air": 0.2,
	"screenshake_amount": Vector2(10, 0.2),
	"damage": 0,
	"type": Enums.Attack.P_GROUND_THROW,
	}
	dict_to_spawn_hitbox(info)


func _grab() ->  void:
	if Input.is_action_pressed("left"):
		sprite_2d.flip_h = true

	if Input.is_action_pressed("right"):
		sprite_2d.flip_h = false

	if state in [States.GRABSTANCE]:
		animation_player.play("throw_enemy")
		
		grabbed_enemy.set_physics_process(true)
		grabbed_enemy.hitted(
			self,
			$Sprite2D.flip_h,
			Vector2(-1200, -30),
			1,
			0.1,
			0.1,
			Vector2(0, 0),
			1,
			0,
		)
		grabbed_enemy = null
	elif state in [States.IDLE, States.PARRY_SUCCESS, States.LP1, States.LP2, States.LP3,]: ## <<-- start with this one
		animation_player.play("grab")
func grab_info() -> void:
	var info = {
	"size": Hitbox_type.MEDIUM,
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
	"type": Enums.Attack.P_THROW,
	}
	dict_to_spawn_hitbox(info)
func throw_info() -> void:
	var info = {
	"size": Hitbox_type.MEDIUM,
	"time": 0.1,
	"push_power_ground": Vector2(600, -10),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(1200, -10),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0.2,
	"hitstun_amount_ground": 2,
	"hitlag_amount_air": 0.2,
	"hitstun_amount_air": 2,
	"screenshake_amount": Vector2(0, 0),
	"damage": 1,
	"type": Enums.Attack.NORMAL,
	"zoom": Vector2(0.2, 0.2),
	"pos": $HitBoxPos/GrabAttackPos.position,
	}
	dict_to_spawn_hitbox(info)


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
	"size": Hitbox_type.EXECUTE,
	"time": 0.1,
	"push_power_ground": Vector2(1200, -200),
	"push_type_ground": Enums.Push_types.EXECUTE,
	"push_power_air": Vector2(1200, -200),
	"push_type_air": Enums.Push_types.EXECUTE,
	"hitlag_amount_ground": 0.5,
	"hitstun_amount_ground": 1,
	"hitlag_amount_air": 0.5,
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
	if Input.is_action_pressed("left"):
		sprite_2d.flip_h = true

	if Input.is_action_pressed("right"):
		sprite_2d.flip_h = false

	var offset = Vector2(180, 0)
	if not sprite_2d.flip_h:
		offset.x *= -1
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", pos+offset, 0.2).set_trans(Tween.TRANS_CUBIC)

func enter_grab_stance() -> void:
	animation_player.play("grab_stance")


func set_collision_no_hit_enemy() -> void:
	collision_layer = 0b00000000000000000001
	collision_mask = 0b00000000000000001101


func set_collision_normal() -> void:
	collision_layer = 0b00000000000000000001
	collision_mask = 0b00000000000000001110


func set_collision_noclip() -> void:
	collision_layer = 0b00000000000000000000
	collision_mask = 0b00000000000000000000


func set_collision_ded() -> void:
	collision_layer = 0b00000000000000000000
	collision_mask = 0b00000000000000001000

func is_pressing_right() -> int:
	if Input.is_action_pressed("right"):
		return 2
	elif Input.is_action_pressed("left"):
		return 1
	else:
		return 0


func toggle_flip_h() -> void:
	sprite_2d.flip_h = !sprite_2d.flip_h


func spawn_sand_spark() -> void:
	if sprite_2d.flip_h:
		ObjectPooling.spawn_sand_sparkL(position + Vector2(-10, 50))
	else:
		ObjectPooling.spawn_sand_sparkR(position + Vector2(10, 50))


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
		"ta",
		"spell",
		"tan",
		"grab",
		"throw_enemy",
		"air_throw",
		"air_spd_burst",
		"forward_hp",
		"wall_throw",
		"ground_grab",
		"place_enemy",
		"wall_abel_combo2",
		"wall_abel_combo",
		"late_parry",
		]:
		animation_player.play("idle")
	if anim_name in ["ded", "execute"]:
		# set_collision_noclip()
		if get_tree().current_scene.name == "training":
			SceneTransition.change_scene("res://scenes/training.tscn")
		else:
			get_parent().get_node("CanvasLayer/RestartMenu").open_menu()
		# queue_free()


func _on_hp_out() -> void:
	print("ARE YOU READY?")
	is_ded = true
	set_collision_noclip()
	animation_player.play("ded")
	# set_collision_ded()
	# _slow_moion_no_sfx(0.5, 0.5)

	# get_parent().get_node("CanvasLayer/RestartMenu").open_menu()


func _on_execute_area_r_body_entered(body: Node2D) -> void:
	body_in_execution_ranges.append(body)


func _on_execute_area_r_body_exited(body: Node2D) -> void:
	body_in_execution_ranges.erase(body)
