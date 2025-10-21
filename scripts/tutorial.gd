extends Node2D

const MAIN_MENU = preload("uid://dystn5u444ihq")
@onready var press_key_label: Label = $CanvasLayer/PressKeyLabel
const ENEMY_01 = preload("res://nodes/enemy_01.tscn")
const HIT_2 = preload("res://media/sfxs/Hit2.wav")
@onready var player: CharacterBody2D = $Player
@onready var enemy: CharacterBody2D = $Enemy
@onready var command_label: RichTextLabel = $CanvasLayer/CommandLabel

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


func enemy_throw_practice() -> void:
	enemy_tween = create_tween().set_loops()
	enemy_tween.tween_callback(enemy._throw_ground).set_delay(1.0)


func kill_all_tween() -> void:
	for tween in get_tree().get_processed_tweens():
		tween.kill()


func enemy_throw_practice2() -> void:
	for tween in get_tree().get_processed_tweens():
		tween.kill()
	enemy_tween = create_tween().set_loops()
	enemy_tween.tween_callback(enemy._throw_float).set_delay(1.0)


func _ready() -> void:
	player.move_hud_away()
	Settings.current_stage = "res://scenes/tutorial.tscn"
	CameraManager.set_screen_lock(0, 1940, 135, 1029)
	command_label.text = "Light Attack"
	press_key_label.text = "Press " + InputMap.action_get_events("lp")[0].as_text()
	AttackQueue.stop_queue_timer()


func _input(event: InputEvent) -> void:
	match tutorial_state:
		LIGHT_ATTACK:
			if event.is_action_pressed("lp"):
				tutorial_state = HEAVY_ATTACK
				command_label.text = "Heavy Attack / Throw break"
				press_key_label.text = "Press " + InputMap.action_get_events("hp")[0].as_text()
		HEAVY_ATTACK:
			if event.is_action_pressed("hp"):
				tutorial_state = BLOCK
				command_label.text = "Block"
				press_key_label.text = "Press " + InputMap.action_get_events("block")[0].as_text()
		BLOCK:
			if event.is_action_pressed("block"):
				tutorial_state = DODGE
				command_label.text = "Dodge"
				press_key_label.text = "Press " + InputMap.action_get_events("dodge")[0].as_text()
		DODGE:
			if event.is_action_pressed("dodge"):
				tutorial_state = THROW_GROUND
				command_label.text = "Throw break [color=purple]purple[/color]"
				press_key_label.text = "Press " + InputMap.action_get_events("hp")[0].as_text()
		THROW_GROUND:
			enemy_throw_practice()
			if player.state == 8: # PARRY_SUCCESS
				tutorial_state = THROW_FLOAT
				command_label.text = "Throw break [color=blue]blue[/color]"
				press_key_label.text = "Press " + InputMap.action_get_events("lp")[0].as_text()
				kill_all_tween()
				enemy_throw_practice2()
		THROW_FLOAT:
			if player.state == 8: # PARRY_SUCCESS
				kill_all_tween()
				tutorial_state = EXECUTE
				command_label.text = "Execute"
				press_key_label.text = "Press " + InputMap.action_get_events("execute")[0].as_text()
				spawn_executable_enemy()
		EXECUTE:
			if event.is_action_pressed("execute"):
				tutorial_state = THE_END
				command_label.text = "Yay! You are ready! (Hopefully)"
				press_key_label.text = "Press " + InputMap.action_get_events("ui_cancel")[0].as_text()
		THE_END:
			if event.is_action_pressed("ui_cancel"):
				SceneTransition.change_scene("res://scenes/intro.tscn")
