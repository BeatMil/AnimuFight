extends "res://scripts/sub_base_menu.gd"


# @onready var button_2: Button = $Group/VBoxContainer/HBoxContainerR/Button2
# @onready var button: Button = $Group/VBoxContainer/HBoxContainerL/MarginContainer/Button
@onready var player: CharacterBody2D = $Group/HBoxContainer/HBoxContainerR/MarginContainer/SubViewportContainer/SubViewport/Player
@onready var player_pos: Marker2D = $Group/HBoxContainer/HBoxContainerR/MarginContainer/SubViewportContainer/SubViewport/PlayerPos
@onready var enemy: CharacterBody2D = $Group/HBoxContainer/HBoxContainerR/MarginContainer/SubViewportContainer/SubViewport/Enemy
@onready var enemy_pos: Marker2D = $Group/HBoxContainer/HBoxContainerR/MarginContainer/SubViewportContainer/SubViewport/EnemyPos

## Check skill tree
@onready var move_tatsu: Control = $Group/HBoxContainer/VBoxContainerL/MoveTatsu

var tween = create_tween()


func _ready() -> void:
	player.command_list_dummy()
	reset_position()


func focus_disable() -> void:
	pass
	tween.kill()
	# button.focus_mode = Control.FOCUS_NONE
	# button_2.focus_mode = Control.FOCUS_NONE


func focus_enable() -> void:
	print("subskillmenu focused")
	if SkillTree.skill_dict["tatsu"]:
		move_tatsu.foreground.visible = false
	# button.focus_mode = Control.FOCUS_ALL
	# button_2.focus_mode = Control.FOCUS_ALL


func reset_position() -> void:
	player.position = player_pos.position
	enemy.position = enemy_pos.position
	enemy.velocity = Vector2.ZERO
	enemy.hp_bar.resurrect(20)


func _on_move_1_selected() -> void:
	reset_position()
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
	reset_position()
	tween.kill()
	tween = create_tween()
	tween.tween_callback(enemy.animation_player.play.bind("idle"))
	tween.tween_callback(player.play_animation.bind("hp"))
	tween.tween_interval(1)
	tween.tween_callback(_on_move_2_selected)


func _on_move_jin_12_selected() -> void:
	tween.kill()

	# If tatsu not unlock then don't show move
	if not SkillTree.skill_dict["jin1+2"]:
		return

	reset_position()

	tween = create_tween()
	tween.tween_callback(enemy.animation_player.play.bind("idle"))
	tween.tween_callback(player._push_x.bind(100))
	tween.tween_callback(player.play_animation.bind("jin1+2"))
	tween.tween_interval(1.5)
	tween.tween_callback(_on_move_jin_12_selected)


func _on_move_tatsu_selected() -> void:
	tween.kill()

	# If tatsu not unlock then don't show move
	if not SkillTree.skill_dict["tatsu"]:
		return

	reset_position()

	tween = create_tween()
	tween.tween_callback(enemy.animation_player.play.bind("idle"))
	tween.tween_callback(player.play_animation.bind("tatsu"))
	tween.tween_interval(2)
	tween.tween_callback(_on_move_tatsu_selected)
