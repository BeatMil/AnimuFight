extends "res://scripts/base_character.gd"

signal ded


#############################################################
## Node Ref
#############################################################
@onready var debug_label: Label = $PlayerCanvasLayer/DebugLabel
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var hit_noise = preload("res://media/sfxs/gc_punch_whiff.wav")
@onready var air_throw_pos_r: Marker2D = $HitBoxPos/AirThrowPosR
@onready var air_throw_pos_l: Marker2D = $HitBoxPos/AirThrowPosL
@onready var grab_pos_r: Marker2D = $HitBoxPos/GrabPosR
@onready var grab_pos_l: Marker2D = $HitBoxPos/GrabPosL
@onready var hp_bar_2: TextureProgressBar = $PlayerCanvasLayer/HpBar2
@onready var profile_player: AnimationPlayer = $PlayerCanvasLayer/Profile/AnimationPlayer
@onready var command_history: VBoxContainer = $PlayerCanvasLayer/CommandHistory
const COMMAND_BOX = preload("res://nodes/command_box.tscn")
@onready var god_fist_player: AudioStreamPlayer = $GodFistPlayer
const STRONG_PUNCH = preload("uid://b6dtaoivlmcyf")
@onready var hud_player: AnimationPlayer = $PlayerCanvasLayer/AnimationPlayer

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

var current_input := ""
var command_buffer_count := 0

var debug_input_event = null

var is_controllable = true

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


enum P_States {
	IDLE,
	CHARGE_LV1,
	CHARGE_LV2,
	CAN_EWGF,
	}

var p_state = P_States.IDLE

# var input_history := ["right","left","n","right","right","n","n","n","n","right"]
# var input_history := ["right","left","n","right","right","n","n","n","n","right","left"]
# var input_history := ["n","n","n","n","right","right","right","right","right"]
# var input_history := ["n","right","n","n","n","n","right","right","right","right","right"]
var input_history := []

var thrower: CharacterBody2D
var throwee: CharacterBody2D


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
		# debug_label.text += "\n%s"%command_buffer_count
		# debug_label.text += "\n%s"%[input_history]
		# debug_label.text += "\nGoh"
		# debug_label.text += "\n%s"%Input.is_action_pressed("block")
		# debug_label.text += "\n%s"%debug_input_event
		debug_label.text += "\n%s"%next_move
		# debug_label.text += "\nCameraPos: %s"%$Camera.global_position


func _input(event: InputEvent) -> void:
	if is_ded:
		return

	if not is_controllable:
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
	if state not in [States.BOUNCE_STUNNED, States.WALL_BOUNCED, States.IFRAME, States.AIR_SPD, States.THROW_BREAKABLE]:
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
	if state in [States.PARRY, States.BLOCK, States.DODGE_SUCCESS]:
		if Input.is_action_pressed("block"):
			if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right") or\
				Input.is_action_just_pressed("dodge"):
				state = States.DODGE
				animation_player.play("dodge")
		elif Input.is_action_just_released("block"):
			_add_block_buffer_time()

	if state in [States.DODGE_SUCCESS]:
		if Input.is_action_pressed("block"):
			if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right") or\
				Input.is_action_just_pressed("dodge"):
				state = States.DODGE
				animation_player.stop()
				animation_player.play("dodge")


func _physics_process(delta: float) -> void:
	if is_ded:
		return

	if hitlag_timer > 0:
		physic_input(delta)
		hitlag_timer -= delta
		return

	if is_controllable:
		physic_input(delta)
	_check_wall_bounce()

	if is_on_floor():
		if state == States.AIR:
			animation_player.play("idle")
			state = States.IDLE
			p_state = P_States.IDLE
	else:
		if state in [States.IDLE, States.DOWN_HP]:
			state = States.AIR
	
	if state == States.AIR:
		animation_player.play("jump")
		friction = 0.07

	# Left/Right movement
	if is_controllable:
		if state in [States.IDLE, States.AIR]:
		# if state in [States.IDLE]:
			if Input.is_action_pressed("left") and Input.is_action_pressed("right"):
				_lerp_velocity_x()
			elif Input.is_action_pressed("left"):
				_move_left(delta)
			elif Input.is_action_pressed("right"):
				_move_right(delta)
			else:
				_lerp_velocity_x()
		else:
			## Adding friction like this is not gonna go well (っ˘̩╭╮˘̩)っ 
			friction = 0.1
			_lerp_velocity_x()
	else:
		friction = 0.1
		_lerp_velocity_x()
	
	# Jump
	if state in [States.IDLE, States.DOWN_HP, States.DASH, States.WAVEDASH] \
		and is_controllable:
		handle_jump_buffer(delta)

	# Jump buffer
	if jump_buffer_timer > 0:
		_jump(delta)
		if state in [States.DASH, States.WAVEDASH]:
			_push_x(300)
			state = States.AIR
			# await get_tree().physics_frame
		jump_buffer_timer = 0

	# Tech roll
	if state in [States.BOUNCE_STUNNED, States.WALL_BOUNCED]:
		if is_on_floor():
			tech_roll_timer -= delta
		else:
			tech_roll_timer = tech_roll_time
	
	## Animation Section
	# Walking animation
	if is_controllable:
		if state in [States.IDLE]:
			if Input.is_action_pressed("left") and Input.is_action_pressed("right"):
				animation_player.play("idle")
			elif Input.is_action_pressed("left"):
				animation_player.play("walk")
			elif Input.is_action_pressed("right"):
				animation_player.play("walk")
			else:
				animation_player.play("idle")

	# Reset throwee
	if state in [States.IDLE, States.AIR, States.DASH]:
		throwee = null

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

	##################
	## Block buffer
	##################
	if block_buffer_timer > 0 and state in [States.BLOCK, States.PARRY]:
		block_buffer_timer -= delta
	elif block_buffer_timer < 0 and state in [States.BLOCK, States.PARRY]:
		animation_player.play("idle")
		block_buffer_timer = 0

	## BLOCK
	## Must check every frame, can't put in _input cause it only check when press and release
	if state in can_block_states_hold and is_controllable:
		if Input.is_action_pressed("block"):
			state = States.PARRY
			animation_player.play("block")
	
	## Air SPD burst
	if is_on_floor() and state == States.AIR_SPD:
		# state = States.ATTACK
		animation_player.play("air_spd_burst")


func physic_input(_delta):
	if Input.is_action_pressed("lp") and Input.is_action_pressed("hp"):
		if input_history.size() > 1:
			if input_history[-2]["frame"] < 7 and (\
				input_history[-2]["command"].find("h") > -1 or \

				input_history[-2]["command"].find("l") > -1):
				_lp_hp()
		queue_move(_lp_hp)
	elif Input.is_action_just_pressed("lp"):
		if is_on_floor():
			if Input.is_action_pressed("down"):
				queue_move(_down_lp)
			else:
				queue_move(_lp)
		else:
			queue_move(_air_lp)
	elif Input.is_action_just_pressed("hp"):
		if Input.is_action_pressed("down"):
			queue_move(_charge_attack)
		else:
			queue_move(_hp)
	elif Input.is_action_just_released("hp"):
		queue_move(_charge_attack_release)
	elif Input.is_action_just_pressed("grab"):
		queue_move(_grab)

	_check_input_history()

	# if state in [States.THROW_BREAKABLE]:
	match animation_player.current_animation:
		"throw_stunned_ground":
			if Input.is_action_just_pressed("lp") and Input.is_action_just_pressed("hp"):
				animation_player.play("hitted")
				next_move = null
			elif Input.is_action_just_pressed("hp"):
				# Throw break
				animation_player.play("throw_break")
				next_move = null
				_slow_moion_no_sfx(0.8, 0.1)
				if thrower.position.x > position.x:
					sprite_2d.flip_h = false
				else:
					sprite_2d.flip_h = true
			elif Input.is_action_just_pressed("lp"):
				animation_player.play("hitted")
				next_move = null
		"throw_stunned_float":
			if Input.is_action_just_pressed("lp") and Input.is_action_just_pressed("hp"):
				animation_player.play("hitted")
				next_move = null
			elif Input.is_action_just_pressed("lp"):
				# Throw break
				animation_player.play("throw_break")
				next_move = null
				_slow_moion_no_sfx(0.8, 0.1)
				if thrower.position.x > position.x:
					sprite_2d.flip_h = false
				else:
					sprite_2d.flip_h = true
			elif Input.is_action_just_pressed("hp"):
				animation_player.play("hitted")
				next_move = null

	if (Input.is_action_just_pressed("down")\
	or Input.is_action_just_pressed("block")) \
	and state in [States.BOUNCE_STUNNED, States.WALL_BOUNCED]\
	and is_on_floor() and tech_roll_timer > 0:
		animation_player.play("techroll")
		hp_bar.hp_up_late_parry()


#############################################################
## Public function
#############################################################
func set_camera(value: bool):
	$Camera.get_node("Camera2D").enabled = value


func get_camera() -> Camera2D:
	return $Camera.get_node("Camera2D")

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


func set_thrower(the_guy: CharacterBody2D) -> void:
	thrower = the_guy


func set_throwee(the_guy: CharacterBody2D) -> void:
	throwee = the_guy


func play_animation(animation: String) -> void:
	animation_player.play(animation)


func set_flip_h(value: bool) -> void:
	sprite_2d.flip_h = value


func move_hud_away() -> void:
	hud_player.play("move_away")


func move_hud_back() -> void:
	hud_player.play("move_back")


func set_is_controllable(value: bool) -> void:
	is_controllable = value


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


func play_hit_random_pitch():
	audio_stream_player.stream = hit_noise
	audio_stream_player.pitch_scale = randf_range(0.8, 1.2)
	audio_stream_player.play()


func _check_input_history() -> void:
	var new_input = ""
	if Input.is_action_pressed("left") and Input.is_action_pressed("right"):
		new_input += "5"
	elif Input.is_action_pressed("jump") and Input.is_action_pressed("down"):
		new_input += "5"
	elif Input.is_action_pressed("down") and Input.is_action_pressed("right"):
		new_input += "3"
	elif Input.is_action_pressed("down") and Input.is_action_pressed("left"):
		new_input += "1"
	elif Input.is_action_pressed("jump") and Input.is_action_pressed("left"):
		new_input += "7"
	elif Input.is_action_pressed("jump") and Input.is_action_pressed("right"):
		new_input += "9"
	elif Input.is_action_pressed("left"):
		new_input += "4"
	elif Input.is_action_pressed("right"):
		new_input += "6"
	elif Input.is_action_pressed("jump"):
		new_input += "8"
	elif Input.is_action_pressed("down"):
		new_input += "2"
	else:
		new_input += "5"

	if Input.is_action_pressed("lp"):
		new_input += "l"
	if Input.is_action_pressed("hp"):
		new_input += "h"
	
	var input_size = 26
	if current_input == new_input:
		if input_history:
			input_history[-1]["frame"] += 1
		command_history.get_child(0).increament_frame()
		command_buffer_count += 1
	else:
		var map_input = {"command": new_input, "frame": 1}
		input_history.append(map_input)
		current_input = new_input

		command_buffer_count = 0
	
		if len(input_history) > input_size:
			input_history.pop_front()

		# fill command history with command_box
		var command_box = COMMAND_BOX.instantiate()
		command_box.command = map_input["command"]
		command_box.frame = map_input["frame"]
		command_history.add_child(command_box)
		command_history.move_child(command_box, 0)

	if command_buffer_count >= input_size:
		input_history.clear()
		command_buffer_count = 0

	var dash_right = Command.new(["6","5","6"])
	var dash_left = Command.new(["4","5","4"])
	var wave_dash_right = Command.new(["6","5","2","3"])
	var wave_dash_left = Command.new(["4","5","2","1"])
	var fake_wave_dash_right = Command.new(["5","2","3"])
	var fake_wave_dash_left = Command.new(["5","2","1"])
	var EWGF_right = Command.new(["6","5","2","3l"])
	var EWGF_left = Command.new(["4","5","2","1l"])
	var fake_EWGF_right = Command.new(["5","2","3l"])
	var fake_EWGF_left = Command.new(["5","2","1l"])
	for i in range(len(input_history)-1, -1, -1):
		dash_right.calculate(input_history[i]["command"])
		dash_left.calculate(input_history[i]["command"])
		wave_dash_right.calculate(input_history[i]["command"])
		wave_dash_left.calculate(input_history[i]["command"])
		fake_wave_dash_right.calculate(input_history[i]["command"])
		fake_wave_dash_left.calculate(input_history[i]["command"])
		EWGF_right.calculate(input_history[i]["command"])
		fake_EWGF_right.calculate(input_history[i]["command"])
		EWGF_left.calculate(input_history[i]["command"])
		fake_EWGF_left.calculate(input_history[i]["command"])
	if fake_wave_dash_right.get_command_complete():
		queue_move(_wave_dash_right)
		input_history.clear()
	if fake_wave_dash_left.get_command_complete():
		queue_move(_wave_dash_left)
		input_history.clear()
	if dash_right.get_command_complete(): 
		queue_move(_dash_right)
		input_history.clear()
	if dash_left.get_command_complete():
		queue_move(_dash_left)
		input_history.clear()
	if wave_dash_left.get_command_complete():
		queue_move(_wave_dash_left)
		input_history.clear()
	if wave_dash_right.get_command_complete():
		queue_move(_wave_dash_right)
		input_history.clear()
	if EWGF_right.get_command_complete():
		queue_move(_EWGF)
		input_history.clear()
	if fake_EWGF_right.get_command_complete():
		queue_move(_EWGF)
		input_history.clear()
	if EWGF_left.get_command_complete():
		queue_move(_EWGF)
		input_history.clear()
	if fake_EWGF_left.get_command_complete():
		queue_move(_EWGF)
		input_history.clear()


func _play_profile_hitted() -> void:
	profile_player.play("hitted")


func play_EWGF_sfx() -> void:
	god_fist_player.stream = STRONG_PUNCH
	god_fist_player.play()
	ObjectPooling.spawn_EWGF_spark(position, sprite_2d.flip_h)


#############################################################
## Fix stuck in blocking
#############################################################
func _add_block_buffer_time() -> void:
	block_buffer_timer = block_buffer_time


#############################################################
## Command list?
#############################################################
var cant_dash_state = [
	States.DODGE,
	States.HIT_STUNNED,
	States.BOUNCE_STUNNED,
	States.WALL_BOUNCED,
	States.GRABBED,
	States.IFRAME,
	States.AIR_SPD,
	States.THROW_BREAKABLE,
	]

var cant_wave_dash_state = [
	States.DODGE,
	States.HIT_STUNNED,
	States.BOUNCE_STUNNED,
	States.WALL_BOUNCED,
	States.GRABBED,
	States.IFRAME,
	States.AIR_SPD,
	States.THROW_BREAKABLE,
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


func _wave_dash_left() -> void:
	if state in cant_wave_dash_state:
		return
	sprite_2d.flip_h = true
	animation_player.play("wave_dash")


func _wave_dash_right() -> void:
	if state in cant_dash_state:
		return
	sprite_2d.flip_h = false
	animation_player.play("wave_dash")


func _EWGF() -> void:
	# if current_input == "3l"
	# 	sprite_2d.flip_h = false
	# else:
	# 	sprite_2d.flip_h = true
	# animation_player.play("charge_attack_release_lv2")
	animation_player.play("EWGF")


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
		States.WAVEDASH,
	]:
		return

	if Input.is_action_pressed("left"):
		sprite_2d.flip_h = true

	if Input.is_action_pressed("right"):
		sprite_2d.flip_h = false
	
	# if p_state == P_States.CAN_EWGF:
		# animation_player.play("charge_attack_release_lv2")
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
func jin1plus2_info() -> void:
	var info = {
	"size": Hitbox_type.MEDIUM,
	"time": 0.1,
	"push_power_ground": Vector2(50, 0),
	"push_type_ground": Enums.Push_types.NORMAL,
	"push_power_air": Vector2(50, -50),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0,
	"hitstun_amount_ground": 0.5,
	"hitlag_amount_air": 0,
	"hitstun_amount_air": 0.1,
	"screenshake_amount": Vector2(0, 0),
	"damage": 2,
	"type": Enums.Attack.NORMAL,
	"pos": $HitBoxPos/LpPos.position,
	}
	dict_to_spawn_hitbox(info)
func jin1plus2_end_info() -> void:
	var info = {
	"size": Hitbox_type.MEDIUM,
	"time": 0.1,
	"push_power_ground": Vector2(300, -50),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(300, -50),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0.1,
	"hitstun_amount_ground": 0.2,
	"hitlag_amount_air": 0.1,
	"hitstun_amount_air": 0.1,
	"screenshake_amount": Vector2(0, 0),
	"damage": 4,
	"type": Enums.Attack.NORMAL,
	"pos": $HitBoxPos/LpPos.position,
	}
	dict_to_spawn_hitbox(info)


func _air_lp() ->  void:
	if state not in [
		States.AIR,
		States.AIR_LP1,
	]:
		return

	if Input.is_action_pressed("left"):
		sprite_2d.flip_h = true

	if Input.is_action_pressed("right"):
		sprite_2d.flip_h = false

	if state == States.AIR_LP1:
		animation_player.play("jump_attack_2")
	else: ## <<-- start with this one
		animation_player.play("jump_attack")
func air_lp_info() -> void:
	var info = {
	"size": Hitbox_type.MEDIUM,
	"time": 0.1,
	"push_power_ground": Vector2(50, 0),
	"push_type_ground": Enums.Push_types.NORMAL,
	"push_power_air": Vector2(200, -50),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0.0,
	"hitstun_amount_ground": 0.1,
	"hitlag_amount_air": 0.0,
	"hitstun_amount_air": 0.1,
	"screenshake_amount": Vector2(0, 0),
	"damage": 1,
	"type": Enums.Attack.NORMAL,
	"pos": $HitBoxPos/LpPos.position,
	}
	dict_to_spawn_hitbox(info)
func air_lp_info2() -> void:
	var info = {
	"size": Hitbox_type.AIR_THROW,
	"time": 0.1,
	"push_power_ground": Vector2(50, 0),
	"push_type_ground": Enums.Push_types.NORMAL,
	"push_power_air": Vector2(200, -50),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0.1,
	"hitstun_amount_ground": 0.5,
	"hitlag_amount_air": 0.1,
	"hitstun_amount_air": 0.1,
	"screenshake_amount": Vector2(0, 0),
	"damage": 1,
	"type": Enums.Attack.NORMAL,
	"pos": $HitBoxPos/LpPos.position,
	}
	dict_to_spawn_hitbox(info)

func _hp() ->  void:
	if state not in [
		States.IDLE,
		States.AIR,
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
	elif Input.is_action_pressed("jump"):
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

func _down_hp() ->  void:
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

	animation_player.play("down_hp")


func _charge_attack() ->  void:
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

	animation_player.play("charge_attack")


func _charge_attack_release() ->  void:
	if state not in [
		# States.PARRY_SUCCESS,
		# States.DODGE_SUCCESS,
		States.DOWN_HP
		]: ## <<-- start with this one
		return

	if Input.is_action_pressed("left"):
		sprite_2d.flip_h = true

	if Input.is_action_pressed("right"):
		sprite_2d.flip_h = false

	if p_state == P_States.CHARGE_LV1:
		animation_player.play("charge_attack_release_lv1")
	elif p_state == P_States.CHARGE_LV2:
		animation_player.play("charge_attack_release_lv2")
	else:
		animation_player.play("down_hp")


func hp_info() ->  void:
	var info = {
	"size": Hitbox_type.MEDIUM,
	"time": 0.1,
	"push_power_ground": Vector2(800, -100),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(1200, -100),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0.3,
	"hitstun_amount_ground": 1,
	"hitlag_amount_air": 0.2,
	"hitstun_amount_air": 1,
	"screenshake_amount": Vector2(10, 0.2),
	"damage": 4,
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
func throw_break_info() ->  void:
	var info = {
	"size": Hitbox_type.SMALL,
	"time": 0.1,
	"push_power_ground": Vector2(200, 0),
	"push_type_ground": Enums.Push_types.NORMAL,
	"push_power_air": Vector2(200, -0),
	"push_type_air": Enums.Push_types.NORMAL,
	"hitlag_amount_ground": 0.1,
	"hitstun_amount_ground": 1,
	"hitlag_amount_air": 0.0,
	"hitstun_amount_air": 1,
	"screenshake_amount": Vector2(10, 0.1),
	"damage": 2,
	"type": Enums.Attack.UNBLOCK,
	"pos_direct": thrower.global_position - global_position,
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
	"damage": 1,
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
		States.DOWN_HP,
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


func _down_lp() ->  void:
	if state not in [
		States.IDLE,
		States.DASH,
		States.PARRY_SUCCESS,
		States.DODGE_SUCCESS,
		States.LP1,
		States.LP2,
		States.LP3,
		States.WAVEDASH,
		]: ## <<-- start with this one
		return

	if Input.is_action_pressed("left"):
		sprite_2d.flip_h = true

	if Input.is_action_pressed("right"):
		sprite_2d.flip_h = false

	if p_state == P_States.CAN_EWGF and not Input.is_action_pressed("right")\
		and not Input.is_action_pressed("left"):
		animation_player.play("jin1+2")
	elif p_state == P_States.CAN_EWGF:
		animation_player.play("WGF")
	else:
		animation_player.play("jin1+2")


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
	"damage": 0,
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
func ground_punch_info() ->  void:
	var info = {
	"size": Hitbox_type.GROUND_THROW,
	"time": 0.1,
	"push_power_ground": Vector2(100, -100),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(100, 0),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0,
	"hitstun_amount_ground": 0,
	"hitlag_amount_air": 0.2,
	"hitstun_amount_air": 0.2,
	"screenshake_amount": Vector2(20, 0.2),
	"damage": 5,
	"type": Enums.Attack.UNBLOCK,
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
func charge_lv1_info() ->  void:
	var info = {
	"size": Hitbox_type.LARGE,
	"time": 0.1,
	"push_power_ground": Vector2(100, -300),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(100, -100),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0.1,
	"hitstun_amount_ground": 0.1,
	"hitlag_amount_air": 0.0,
	"hitstun_amount_air": 0.1,
	"screenshake_amount": Vector2(10, 0.1),
	"damage": 4,
	"type": Enums.Attack.NORMAL,
	"pos": $HitBoxPos/DownHpPos.position,
	# "zoom": Vector2(1, 1),
	}
	dict_to_spawn_hitbox(info)
func charge_lv2_info() ->  void:
	var info = {
	"size": Hitbox_type.LARGE,
	"time": 0.1,
	"push_power_ground": Vector2(100, -600),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(100, -200),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0.1,
	"hitstun_amount_ground": 0.1,
	"hitlag_amount_air": 0.0,
	"hitstun_amount_air": 0.1,
	"screenshake_amount": Vector2(10, 0.1),
	"damage": 10,
	"type": Enums.Attack.NORMAL,
	"pos": $HitBoxPos/DownHpPos.position,
	# "zoom": Vector2(1, 1),
	}
	dict_to_spawn_hitbox(info)
func EWGF_info() -> void:
	var info = {
	"size": Hitbox_type.LARGE,
	"time": 0.1,
	"push_power_ground": Vector2(100, -200),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(200, -120),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0.2,
	"hitstun_amount_ground": 0.1,
	"hitlag_amount_air": 0.0,
	"hitstun_amount_air": 0.1,
	"screenshake_amount": Vector2(10, 0.1),
	"damage": 5,
	"type": Enums.Attack.NORMAL,
	"pos": $HitBoxPos/DownHpPos.position,
	"zoom": Vector2(0.2, 0.2),
	}
	dict_to_spawn_hitbox(info)
func WGF_info() -> void:
	var info = {
	"size": Hitbox_type.LARGE,
	"time": 0.1,
	"push_power_ground": Vector2(200, -50),
	"push_type_ground": Enums.Push_types.KNOCKDOWN,
	"push_power_air": Vector2(200, -120),
	"push_type_air": Enums.Push_types.KNOCKDOWN,
	"hitlag_amount_ground": 0.1,
	"hitstun_amount_ground": 0.1,
	"hitlag_amount_air": 0.0,
	"hitstun_amount_air": 0.1,
	"screenshake_amount": Vector2(10, 0.1),
	"damage": 3,
	"type": Enums.Attack.NORMAL,
	"pos": $HitBoxPos/DownHpPos.position,
	# "zoom": Vector2(1, 1),
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
	CameraManager.zoom(Vector2(0.2, 0.2), 0.3)


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
	collision_layer = 0b00000000001000000000
	collision_mask = 0b00000000000000001101


func set_collision_normal() -> void:
	collision_layer= 0b00000000001000000001
	collision_mask = 0b00000000010100001110


func set_collision_noclip() -> void:
	collision_layer = 0b00000000001000000000
	collision_mask = 0b00000000000000000000


func set_collision_ded() -> void:
	collision_layer = 0b00000000001000000000
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


func _set_p_state(new_state: int) -> void:
	p_state = new_state as P_States


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
		"throw_break",
		"techroll",
		"jump_attack",
		"jump_attack_2",
		"jin1+2",
		"charge_attack_release_lv1",
		"charge_attack_release_lv2",
		"WGF",
		"EWGF",
		]:
		animation_player.play("idle")
	if anim_name in ["ded", "execute"]:
		# set_collision_noclip()
		if get_tree().current_scene.name == "training":
			SceneTransition.change_scene("res://scenes/training.tscn")
		else:
			emit_signal("ded")
		# queue_free()


func _on_hp_out() -> void:
	# is_ded = true
	is_controllable = false
	set_collision_noclip()
	state = States.IDLE
	animation_player.play("ded")
	print("hp_out ded")
	# set_collision_ded()
	# _slow_moion_no_sfx(0.5, 0.5)

	# get_parent().get_node("CanvasLayer/RestartMenu").open_menu()


func _on_execute_area_r_body_entered(body: Node2D) -> void:
	body_in_execution_ranges.append(body)


func _on_execute_area_r_body_exited(body: Node2D) -> void:
	body_in_execution_ranges.erase(body)


func _on_animation_player_animation_started(anim_name: StringName) -> void:
	if anim_name in ["air_spd_burst", "forward_hp"]:
		set_throwee(null)
