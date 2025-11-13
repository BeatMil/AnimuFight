extends "res://scripts/sub_base_menu.gd"


# @onready var button_2: Button = $Group/VBoxContainer/HBoxContainerR/Button2
# @onready var button: Button = $Group/VBoxContainer/HBoxContainerL/MarginContainer/Button
@onready var player: CharacterBody2D = $Group/HBoxContainer/HBoxContainerR/MarginContainer/SubViewportContainer/SubViewport/Player
@onready var player_pos: Marker2D = $Group/HBoxContainer/HBoxContainerR/MarginContainer/SubViewportContainer/SubViewport/PlayerPos
@onready var enemy: CharacterBody2D = $Group/HBoxContainer/HBoxContainerR/MarginContainer/SubViewportContainer/SubViewport/Enemy
@onready var enemy_pos: Marker2D = $Group/HBoxContainer/HBoxContainerR/MarginContainer/SubViewportContainer/SubViewport/EnemyPos


var tween = create_tween()


func _ready() -> void:
	player.command_list_dummy()
	reset_player()


func focus_disable() -> void:
	pass
	tween.kill()
	# button.focus_mode = Control.FOCUS_NONE
	# button_2.focus_mode = Control.FOCUS_NONE


func focus_enable() -> void:
	pass
	# button.focus_mode = Control.FOCUS_ALL
	# button_2.focus_mode = Control.FOCUS_ALL


func reset_player() -> void:
	player.position = player_pos.position
	enemy.position = enemy_pos.position
	enemy.hp_bar.resurrect(20)


func _on_move_1_selected() -> void:
	reset_player()
	tween.kill()
	tween = create_tween()
	tween.tween_callback(enemy.animation_player.play.bind("idle"))
	tween.tween_callback(player.play_animation.bind("lp1"))
	tween.tween_interval(0.2)
	tween.tween_callback(player.play_animation.bind("lp2"))
	tween.tween_interval(0.3)
	tween.tween_callback(player.play_animation.bind("lp3"))
	tween.tween_interval(1)
	tween.tween_callback(_on_move_1_selected)


func _on_move_2_selected() -> void:
	reset_player()
	tween.kill()
	tween = create_tween()
	tween.tween_callback(enemy.animation_player.play.bind("idle"))
	tween.tween_callback(player.play_animation.bind("hp"))
	tween.tween_interval(1)
	tween.tween_callback(_on_move_2_selected)
