extends Node2D


@onready var command_label: Label = $CanvasLayer/CommandLabel
@onready var press_key_label: Label = $CanvasLayer/PressKeyLabel


enum {
	LIGHT_ATTACK,
	HEAVY_ATTACK,
	BLOCK,
	DODGE,
	EXECUTE,
	THE_END,
}


var tutorial_state = LIGHT_ATTACK


func _ready() -> void:
	Settings.current_stage = "res://scenes/tutorial.tscn"
	command_label.text = "Light Attack"
	press_key_label.text = "Press " + InputMap.action_get_events("lp")[0].as_text()


func _input(event: InputEvent) -> void:
	match tutorial_state:
		LIGHT_ATTACK:
			if event.is_action_pressed("lp"):
				tutorial_state = HEAVY_ATTACK
				command_label.text = "Heavy Attack"
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
		EXECUTE:
			if event.is_action_pressed("execute"):
				tutorial_state = THE_END
				command_label.text = "Yay! You are ready! (Hopefully)"
				press_key_label.text = "Press " + InputMap.action_get_events("ui_cancel")[0].as_text()
