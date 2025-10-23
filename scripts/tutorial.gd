extends Node2D

@onready var press_key_label: RichTextLabel = $CanvasLayer/PressKeyLabel
@onready var player: CharacterBody2D = $Player
@onready var enemy: CharacterBody2D = $Enemy
@onready var command_label: RichTextLabel = $CanvasLayer/CommandLabel
@onready var count_label: RichTextLabel = $CanvasLayer/CountLabel
@onready var nice_label: Label = $CanvasLayer/NiceLabel
@onready var nice_player: AnimationPlayer = $CanvasLayer/NiceLabel/AnimationPlayer
@onready var nice_pos: Marker2D = $CanvasLayer/nice_pos
@onready var repos: Marker2D = $Repos
@onready var controller_icon: Sprite2D = $CanvasLayer/ControllerIcon

const MAIN_MENU = preload("uid://dystn5u444ihq")
const HIT_2 = preload("res://media/sfxs/Hit2.wav")
const ENEMY_01 = preload("uid://b2vaqeiw3q18o")

var block_count = 0
var dodge_count = 0
var throw_break_count = 0
var current_action = "lp"


enum {
	LIGHT_ATTACK,
	HEAVY_ATTACK,
	BLOCK,
	DODGE,
	THROW_GROUND,
	THROW_FLOAT,
	EXECUTE,
	THE_END,
}

var enemy_tween


var tutorial_state = LIGHT_ATTACK


func spawn_executable_enemy() -> void:
	enemy._set_state(0)
	enemy.animation_player.play("IDLE")
	enemy.hitted(
		self,
		true,
		Vector2(20, 0),
		0,
		0,
		1,
		Vector2(10, 0.1),
		10000,
		Enums.Attack.UNBLOCK
	)
	GlobalSoundPlayer.stream = HIT_2
	GlobalSoundPlayer.play()


func spawn_executable_enemy_again() -> void:
	var e = ENEMY_01.instantiate()
	e.position = repos.position
	e.tree_exited.connect(_on_enemy_tree_exited)
	add_child(e)
	await get_tree().create_timer(1).timeout
	e.hitted(
		self,
		true,
		Vector2(20, 0),
		0,
		0,
		1,
		Vector2(10, 0.1),
		10000,
		Enums.Attack.UNBLOCK
	)
	GlobalSoundPlayer.stream = HIT_2
	GlobalSoundPlayer.play()


func enemy_throw_practice() -> void:
	enemy_tween = create_tween().set_loops()
	enemy_tween.tween_callback(enemy._throw_ground).set_delay(1.0)
	print("throw_practice!")


func kill_all_tween() -> void:
	for tween in get_tree().get_processed_tweens():
		tween.kill()
	print("kill all tween")


func enemy_throw_practice2() -> void:
	enemy_tween = create_tween().set_loops()
	enemy_tween.tween_callback(enemy._throw_float).set_delay(1.0)


func enemy_block_practice() -> void:
	enemy_tween = create_tween().set_loops()
	enemy_tween.tween_callback(enemy._lp).set_delay(1.0)
	print("block_practice!")


func enemy_dodge_practice() -> void:
	enemy_tween = create_tween().set_loops()
	enemy_tween.tween_callback(enemy._attack01).set_delay(1.0)


func player_block_count() -> void:
	if tutorial_state == BLOCK:
		block_count += 1
		count_label.text = "Block %s/2"%[block_count]


func player_dodge_count() -> void:
	if tutorial_state == DODGE:
		dodge_count += 1
		count_label.text = "Dodge %s/2"%[dodge_count]


func spawn_green_spark() -> void:
	ObjectPooling.spawn_green_spark(nice_pos.position)


func show_label_base_on_input(human_read) -> void:
	press_key_label.text = "Press %s" % human_read


func show_controller_icon(icon) -> void:
	controller_icon.texture = icon


func player_throw_break_count() -> void:
	print("throw break desu")
	throw_break_count += 1
	if tutorial_state == THROW_GROUND:
		print("throw break purple")
		count_label.text = "Throw break [color=purple]purple[/color] %s/2"%[throw_break_count]
	elif tutorial_state == THROW_FLOAT:
		print("throw break blue")
		count_label.text = "Throw break [color=lightblue]purple[/color] %s/2"%[throw_break_count]


func _ready() -> void:
	player.move_hud_away()
	player.block_success.connect(player_block_count)
	player.dodge_success.connect(player_dodge_count)
	player.throw_break_success.connect(player_throw_break_count)
	Settings.current_stage = "res://scenes/tutorial.tscn"
	CameraManager.set_screen_lock(0, 1940, 135, 1029)
	command_label.text = "Light Attack"
	# press_key_label.text = "Press " + InputMap.action_get_events("lp")[0].as_text()
	# press_key_label.text = "[img]res://media/sprites/char1/FirstChar_block.png[/img]"
	# InputDetector.input_recieved.connect(show_label_base_on_input)
	InputDetector.send_controller_icon.connect(show_controller_icon)
	InputDetector.send_keyboard_icon.connect(show_controller_icon)
	InputDetector.action = "lp"
	AttackQueue.stop_queue_timer()


func _physics_process(_delta: float) -> void:
	match tutorial_state:
		LIGHT_ATTACK:
			if player.animation_player.current_animation == "lp1":
				tutorial_state = HEAVY_ATTACK
				command_label.text = "Heavy Attack"
				InputDetector.action = "hp"
				spawn_green_spark()
				nice_player.play("nice")
		HEAVY_ATTACK:
			if player.animation_player.current_animation == "hp":
				tutorial_state = BLOCK
				command_label.text = "Block"
				InputDetector.action = "block"
				count_label.text = "Block 0/2"
				enemy_block_practice()
				spawn_green_spark()
				nice_player.play("nice")
		BLOCK:
			if block_count >= 2:
				kill_all_tween()
				enemy_dodge_practice()
				tutorial_state = DODGE
				command_label.text = "Dodge"
				count_label.text = "Dodge 0/2"
				InputDetector.action = "dodge"
				enemy_dodge_practice()
				spawn_green_spark()
				nice_player.play("nice")
		DODGE:
			if dodge_count >= 2:
				tutorial_state = THROW_GROUND
				command_label.text = "Throw break [color=purple]purple[/color]"
				InputDetector.action = "hp"
				count_label.text = "Throw break [color=purple]purple[/color] 0/2"
				kill_all_tween()
				enemy_throw_practice()
				spawn_green_spark()
				nice_player.play("nice")
		THROW_GROUND:
			if throw_break_count >= 2:
				throw_break_count = 0
				command_label.text = "Throw break [color=lightblue]blue[/color]"
				InputDetector.action = "lp"
				count_label.text = "Throw break [color=lightblue]blue[/color] 0/2"
				kill_all_tween()
				spawn_green_spark()
				nice_player.play("nice")
				await get_tree().create_timer(1).timeout
				enemy_throw_practice2()
				tutorial_state = THROW_FLOAT
		THROW_FLOAT:
			if throw_break_count >= 2:
				kill_all_tween()
				tutorial_state = EXECUTE
				command_label.text = "Execute"
				InputDetector.action = "execute"
				spawn_green_spark()
				nice_player.play("nice")
				await get_tree().create_timer(1).timeout
				spawn_executable_enemy()
		EXECUTE:
			if player.animation_player.current_animation == "exe_hadoken":
				tutorial_state = THE_END
				command_label.text = "Yay! You are ready! (Hopefully)"
				InputDetector.send_controller_icon.disconnect(show_controller_icon)
				InputDetector.send_keyboard_icon.disconnect(show_controller_icon)
				controller_icon.texture = null
				press_key_label.text = "(♡˙︶˙♡)"
		THE_END:
			await get_tree().create_timer(5).timeout
			SceneTransition.change_scene("res://scenes/intro.tscn")


func _on_enemy_tree_exited() -> void:
	if tutorial_state == EXECUTE:
		spawn_executable_enemy_again()
