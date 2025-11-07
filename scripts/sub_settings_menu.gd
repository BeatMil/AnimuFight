extends "res://scripts/sub_base_menu.gd"


# Controller layout
const PS_LAYOUT = preload("uid://dlgtxmf0o6gvf")
const XBOX_LAYOUT = preload("uid://hirwibir5wuk")
@onready var controller_icon: Button = $HBoxContainer/ControllerIcon
@onready var joy_layout: Sprite2D = $Group/HBoxContainer/ControllerIconButton/JoyLayout


# Key Bind
@onready var key_bind_menu: Control = $Group/KeyBindMenu
@onready var change_key_bind_button: Button = $Group/HBoxContainer/ChangeKeyBindButton


# sub menu buttons
@onready var h_box_container: VBoxContainer = $Group/HBoxContainer


func update_controller_layout() -> void:
	if Settings.controller_type == Settings.ControllerType.XBOX:
		joy_layout.texture = XBOX_LAYOUT
	elif Settings.controller_type == Settings.ControllerType.PS:
		joy_layout.texture = PS_LAYOUT


func _ready() -> void:
	key_bind_menu.visible = false


func _on_controller_icon_button_pressed() -> void:
	if Settings.controller_type == Settings.ControllerType.XBOX:
		Settings.controller_type = Settings.ControllerType.PS
	elif Settings.controller_type == Settings.ControllerType.PS:
		Settings.controller_type = Settings.ControllerType.XBOX
	update_controller_layout()


func _on_change_key_bind_button_pressed() -> void:
	h_box_container.visible = false
	key_bind_menu.display_keys()
	key_bind_menu.grab_focus_move_left()
	key_bind_menu.visible = true
	get_node("../..").set_process_input(false)


func _on_key_bind_menu_close() -> void:
	h_box_container.visible = true
	key_bind_menu.visible = false
	change_key_bind_button.grab_focus()
	get_node("../..").set_process_input(true)
