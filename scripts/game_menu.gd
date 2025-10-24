extends Control


signal close


const PS_LAYOUT = preload("uid://dlgtxmf0o6gvf")
const XBOX_LAYOUT = preload("uid://hirwibir5wuk")
@onready var controller_icon: Button = $HBoxContainer/ControllerIcon
@onready var joy_layout: Sprite2D = $HBoxContainer/ControllerIcon/JoyLayout


func _ready() -> void:
	update_controller_layout()


func _input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed("ui_cancel"):
			_on_back_button_pressed()

func grab_focus_top() -> void:
	controller_icon.grab_focus()


func _on_controller_icon_pressed() -> void:
	if Settings.controller_type == Settings.ControllerType.XBOX:
		Settings.controller_type = Settings.ControllerType.PS
	elif Settings.controller_type == Settings.ControllerType.PS:
		Settings.controller_type = Settings.ControllerType.XBOX
	update_controller_layout()


func update_controller_layout() -> void:
	if Settings.controller_type == Settings.ControllerType.XBOX:
		joy_layout.texture = XBOX_LAYOUT
	elif Settings.controller_type == Settings.ControllerType.PS:
		joy_layout.texture = PS_LAYOUT


func _on_back_button_pressed() -> void:
	print("close game_menu")
	emit_signal("close")
