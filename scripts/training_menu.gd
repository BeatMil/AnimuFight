extends Control


@onready var enemy_1_button: Button = $VBoxContainer/VBoxContainerL/Enemy1Button
@onready var death_zone_button: Button = $VBoxContainer/VBoxContainerL/DeathZoneButton
@onready var key_bind_menu: Control = $KeyBindMenu
@onready var v_box_container_l: VBoxContainer = $VBoxContainer/VBoxContainerL
@onready var key_bind_button: Button = $VBoxContainer/VBoxContainerL/KeyBindButton

signal enemy1
signal enemy2
signal enemy3
signal enemy4
signal death_zone
signal clear


func _ready() -> void:
	key_bind_menu.close.connect(_on_key_bind_menu_close)
	# enemy_1_button.grab_focus()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		self.visible = !self.visible
		get_tree().paused = !get_tree().paused
		if get_tree().paused:
			key_bind_menu.visible = false
			v_box_container_l.visible = true
			enemy_1_button.grab_focus()
			%MenuCursor.move_to(Vector2(576, 472))


func _on_enemy_1_button_pressed() -> void:
	emit_signal("enemy1")


func _on_enemy_2_button_pressed() -> void:
	emit_signal("enemy2")


func _on_clear_button_pressed() -> void:
	emit_signal("clear")


func _on_enemy_3_button_pressed() -> void:
	emit_signal("enemy3")


func _on_enemy_4_button_pressed() -> void:
	emit_signal("enemy4")


func _on_death_zone_button_toggled(toggled_on: bool) -> void:
	emit_signal("death_zone", toggled_on)


func _on_main_menu_button_pressed() -> void:
	SceneTransition.change_scene("res://scenes/main_menu.tscn")


func _on_key_bind_button_pressed() -> void:
	key_bind_menu.visible = true
	key_bind_menu.grab_focus_move_left()
	key_bind_menu.display_keys()
	v_box_container_l.visible = false
	%MenuCursor.visible = false


func _on_key_bind_menu_close() -> void:
	v_box_container_l.visible = true
	%MenuCursor.visible = true
	key_bind_menu.visible = false
	key_bind_button.grab_focus()
