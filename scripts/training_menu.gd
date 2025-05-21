extends Control


@onready var enemy_1_button: Button = $VBoxContainer/VBoxContainerL/Enemy1Button
@onready var death_zone_button: Button = $VBoxContainer/VBoxContainerL/DeathZoneButton

signal enemy1
signal enemy2
signal enemy3
signal enemy4
signal death_zone
signal clear


func _ready() -> void:
	pass
	# enemy_1_button.grab_focus()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		self.visible = !self.visible
		get_tree().paused = !get_tree().paused
		if self.visible:
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
