extends Control


@export var focus_node: Node


@onready var sub_menu_player: AnimationPlayer = $SubMenuPlayer


@export var button_container: Node


func play(anim_name: String) -> void:
	sub_menu_player.play(anim_name)


func focus_on_me() -> void:
	if focus_node:
		focus_node.grab_focus()


func focus_disable() -> void:
	for c in button_container.get_children():
		c.focus_mode = FOCUS_NONE


func focus_enable() -> void:
	for c in button_container.get_children():
		c.focus_mode = FOCUS_ALL
