extends Control


@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@onready var sub_groups: Control = $SubGroups
@onready var sub_game_menu: Control = $SubGroups/SubGameMenu
var groups = []

@onready var tab_container: HBoxContainer = $NavBarBackground/TabContainer
var tab_groups = []

@onready var nav_bar_background: Panel = $NavBarBackground
@onready var panel: Panel = $Panel

@onready var open_close_audio_player: AudioStreamPlayer = $OpenCloseAudioPlayer

var current_menu: int = 0

var stretch_ratio = 2
var fade_white = Color(0.735, 0.735, 0.735)
var normal_white = Color(1, 1, 1, 1)


func _ready() -> void:
	groups = sub_groups.get_children()
	tab_groups = tab_container.get_children()

	# Make sure every sub_menu is invisible
	for g in groups:
		g.play("sub_menu/RESET")

	# Focus on sub game menu
	groups[current_menu].play("sub_menu/fade_in_from_left")
	tab_groups[current_menu].fade_in()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible:
			close_menu()
			print("close big menu!")
		else:
			open_menu()
			print("open big menu!")
	elif event.is_action_pressed("ui_cancel"):
		if visible:
			close_menu()
			print("close big menu!")

	if not visible:
		return

	if event.is_action_pressed("ui_next_tab"):
		next_tab_sfx()
		groups[current_menu].play("sub_menu/fade_out_to_left")
		groups[current_menu].focus_disable()
		tab_groups[current_menu].fade_out()
		

		# Bring current_menu back to start
		if current_menu + 1 >= groups.size():
			current_menu = 0
		else:
			current_menu += 1

		var tween = create_tween()
		tween.tween_callback(
		groups[current_menu].play.bind("sub_menu/fade_in_from_right"))
		tween.tween_callback(
		groups[current_menu].focus_enable)
		tween.tween_callback(
		groups[current_menu].focus_on_me)
		tween.tween_callback(
		tab_groups[current_menu].fade_in)

	if event.is_action_pressed("ui_prev_tab"):
		prev_tab_sfx()
		groups[current_menu].play("sub_menu/fade_out_to_right")
		groups[current_menu].focus_disable()
		tab_groups[current_menu].fade_out()

		# Bring current_menu to the end
		if current_menu - 1 < 0:
			current_menu = groups.size()-1
		else:
			current_menu -= 1

		var tween = create_tween()
		tween.tween_callback(
		groups[current_menu].play.bind("sub_menu/fade_in_from_left"))
		tween.tween_callback(
		groups[current_menu].focus_enable)
		tween.tween_callback(
		groups[current_menu].focus_on_me)
		tween.tween_callback(
		tab_groups[current_menu].fade_in)


func next_tab_sfx() -> void:
	audio_stream_player.pitch_scale = 1
	audio_stream_player.play()


func prev_tab_sfx() -> void:
	audio_stream_player.pitch_scale = 0.8
	audio_stream_player.play()


func open_menu() -> void:
	# pause game
	get_tree().paused = true

	# play sfx
	open_close_audio_player.pitch_scale = 0.7
	open_close_audio_player.play()

	var tween = create_tween()
	tween.tween_property(self, "visible", true, 0)

	# whole modulate
	tween.tween_property(self, "modulate", Color(1,1,1,1), 0.2).from(Color(1,1,1,0))

	# panel
	tween.parallel().tween_property(panel, "position",
	Vector2.ZERO, 0.2).from(Vector2(360, 0))

	# nav_bar
	tween.parallel().tween_property(nav_bar_background, "position",
	Vector2(224, 8), 0.2).from(Vector2(0, 8))
	# tween.parallel().tween_property(panel, "rotation_degrees", 0.0, 0.3) \
	# .from(30).set_trans(Tween.TRANS_EXPO)

	# Focus current_menu
	tween.parallel().tween_callback(groups[current_menu].focus_on_me)


func remove_resume_button() -> void:
	groups[0].remove_resume_button()


func close_menu() -> void:
	# play sfx
	open_close_audio_player.pitch_scale = 1
	open_close_audio_player.play()

	var tween = create_tween()

	# whole modulate
	tween.tween_property(self, "modulate",Color(1,1,1,0) , 0.2).from(Color(1,1,1,1))

	# panel
	tween.parallel().tween_property(panel, "position",
	Vector2(360, 0), 0.2).from(Vector2.ZERO)

	# nav_bar
	tween.parallel().tween_property(nav_bar_background, "position",
	Vector2(0, 8), 0.2).from(Vector2(224, 8))
	# tween.parallel().tween_property(panel, "rotation_degrees", 30, 0.3) \
	# .from(0).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "visible", false, 0)

	# resume game
	get_tree().paused = false


func _on_sub_game_menu_resume_button_press() -> void:
	close_menu()


func click_tab_label(_amount: int) -> void:
	next_tab_sfx()
	groups[current_menu].play("sub_menu/fade_out_to_left")
	groups[current_menu].focus_disable()
	tab_groups[current_menu].fade_out()
	

	# Bring current_menu to specify
	current_menu = _amount

	var tween = create_tween()
	tween.tween_callback(
	groups[current_menu].play.bind("sub_menu/fade_in_from_right"))
	tween.tween_callback(
	groups[current_menu].focus_enable)
	tween.tween_callback(
	groups[current_menu].focus_on_me)
	tween.tween_callback(
	tab_groups[current_menu].fade_in)


func _on_game_label_pressed() -> void:
	click_tab_label(0)


func _on_skill_label_pressed() -> void:
	click_tab_label(1)


func _on_figure_label_pressed() -> void:
	click_tab_label(2)


func _on_note_label_pressed() -> void:
	click_tab_label(3)


func _on_settings_label_pressed() -> void:
	click_tab_label(4)
