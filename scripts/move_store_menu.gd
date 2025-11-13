extends "res://scripts/sub_base_menu.gd"


signal close_store_menu


# @onready var button_2: Button = $Group/VBoxContainer/HBoxContainerR/Button2
# @onready var button: Button = $Group/VBoxContainer/HBoxContainerL/MarginContainer/Button
@onready var player: CharacterBody2D = $Group/HBoxContainer/HBoxContainerR/MarginContainer/SubViewportContainer/SubViewport/Player
@onready var player_pos: Marker2D = $Group/HBoxContainer/HBoxContainerR/MarginContainer/SubViewportContainer/SubViewport/PlayerPos
@onready var enemy: CharacterBody2D = $Group/HBoxContainer/HBoxContainerR/MarginContainer/SubViewportContainer/SubViewport/Enemy
@onready var enemy_pos: Marker2D = $Group/HBoxContainer/HBoxContainerR/MarginContainer/SubViewportContainer/SubViewport/EnemyPos

## Check skill tree
@onready var move_tatsu: Control = $Group/HBoxContainer/VBoxContainerL/MoveTatsu
@onready var move_jin_1_2: Control = $"Group/HBoxContainer/ScrollContainer/VBoxContainerL/MoveJin1+2"

@onready var open_close_audio_player: AudioStreamPlayer = $OpenCloseAudioPlayer
@onready var panel: Panel = $Panel

var tween = create_tween()


func _ready() -> void:
	visible = false
	player.command_list_dummy()
	reset_position()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		close_menu()
		print("nani pause")
		# if move_store_menu.visible:
		# 	move_store_menu.visible = false
		# 	# resume game
		# 	get_tree().paused = false
		# 	print("close move store")
	elif event.is_action_pressed("ui_cancel"):
		close_menu()
		print("nani ui_cancel")
		# if move_store_menu.visible:
		# 	move_store_menu.visible = false
		# 	# resume game
		# 	get_tree().paused = false
		# 	print("close move store")


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


func focus_on_me() -> void:
	move_jin_1_2.grab_focus()


func open_menu() -> void:
	# pause game
	get_tree().paused = true

	# enable physics inside viewport
	PhysicsServer2D.set_active(true)

	# play sfx
	open_close_audio_player.pitch_scale = 0.7
	open_close_audio_player.play()

	var tween2 = create_tween()
	tween2.tween_property(self, "visible", true, 0)

	# whole modulate
	tween2.tween_property(self, "modulate", Color(1,1,1,1), 0.2).from(Color(1,1,1,0))

	# panel
	tween2.parallel().tween_property(panel, "position",
	Vector2.ZERO, 0.2).from(Vector2(360, 0))

	# nav_bar
	# tween2.parallel().tween_property(nav_bar_background, "position",
	# Vector2(224, 8), 0.2).from(Vector2(0, 8))
	# tween2.parallel().tween_property(panel, "rotation_degrees", 0.0, 0.3) \
	# .from(30).set_trans(Tween2.TRANS_EXPO)

	# Focus current_menu
	tween2.parallel().tween_callback(focus_on_me)


func close_menu() -> void:
	if not visible:
		return

	# emit signal
	emit_signal("close_store_menu")

	# resume game
	get_tree().paused = false

	# play sfx
	open_close_audio_player.pitch_scale = 1
	open_close_audio_player.play()

	# stop skill menu from playing movelist
	tween.kill()

	var tween2 = create_tween()

	# whole modulate
	tween2.tween_property(self, "modulate",Color(1,1,1,0) , 0.2).from(Color(1,1,1,1))

	# panel
	tween2.parallel().tween_property(panel, "position",
	Vector2(360, 0), 0.2).from(Vector2.ZERO)

	# nav_bar
	# tween2.parallel().tween_property(nav_bar_background, "position",
	# Vector2(0, 8), 0.2).from(Vector2(224, 8))
	# tween2.parallel().tween_property(panel, "rotation_degrees", 30, 0.3) \
	# .from(0).set_trans(Tween2.TRANS_EXPO)
	tween2.tween_property(self, "visible", false, 0)



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
