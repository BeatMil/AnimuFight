extends Node2D

const MAIN_MENU = preload("uid://dystn5u444ihq")
@onready var command_label: Label = $CanvasLayer/CommandLabel
@onready var press_key_label: Label = $CanvasLayer/PressKeyLabel
const ENEMY_01 = preload("res://nodes/enemy_01.tscn")
const HIT_2 = preload("res://media/sfxs/Hit2.wav")

enum {
	LIGHT_ATTACK,
	HEAVY_ATTACK,
	BLOCK,
	DODGE,
	EXECUTE,
	THE_END,
}


var tutorial_state = LIGHT_ATTACK

func spawn_executable_enemy() -> void:
	var en = ENEMY_01.instantiate()
	en.hp = 1
	en.is_notarget = true
	en.position = $SpawnPos.position
	add_child(en)
	await get_tree().create_timer(0.8).timeout
	en.hitted(
		self,
		true,
		Vector2(20, 0),
		0,
		0,
		1,
		Vector2(10, 0.1),
		1,
		Enums.Attack.UNBLOCK
	)
	GlobalSoundPlayer.stream = HIT_2
	GlobalSoundPlayer.play()

func _ready() -> void:
	Settings.current_stage = "res://scenes/tutorial.tscn"
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
				tutorial_state = EXECUTE
				command_label.text = "Execute"
				press_key_label.text = "Press " + InputMap.action_get_events("execute")[0].as_text()
				spawn_executable_enemy()
		EXECUTE:
			if event.is_action_pressed("execute"):
				tutorial_state = THE_END
				command_label.text = "Yay! You are ready! (Hopefully)"
				press_key_label.text = "Press " + InputMap.action_get_events("ui_cancel")[0].as_text()
	
	if event.is_action_pressed("ui_cancel"):
		SceneTransition.change_scene("res://scenes/main_menu.tscn")
