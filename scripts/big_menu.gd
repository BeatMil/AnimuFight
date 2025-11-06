extends Control


@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@onready var sub_groups: Control = $SubGroups
@onready var sub_game_menu: Control = $SubGroups/SubGameMenu
var groups = []

@onready var tab_container: HBoxContainer = $NavBarBackground/TabContainer
var tab_groups = []


var current_menu: int = 0

var stretch_ratio = 2
var fade_white = Color(0.735, 0.735, 0.735)
var normal_white = Color(1, 1, 1, 1)


func _ready() -> void:
	groups = sub_groups.get_children()
	tab_groups = tab_container.get_children()
	await get_tree().create_timer(1).timeout
	groups[current_menu].play("sub_menu/fade_in_from_left")
	tab_groups[current_menu].fade_in()
	# print("fade in from left")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_next_tab"):
		next_tab_sfx()
		groups[current_menu].play("sub_menu/fade_out_to_left")
		tab_groups[current_menu].fade_out()
		

		# Bring current_menu back to start
		if current_menu + 1 >= groups.size():
			current_menu = 0
		else:
			current_menu += 1

		groups[current_menu].play("sub_menu/fade_in_from_right")
		tab_groups[current_menu].fade_in()

	if event.is_action_pressed("ui_prev_tab"):
		prev_tab_sfx()
		groups[current_menu].play("sub_menu/fade_out_to_right")
		tab_groups[current_menu].fade_out()

		# Bring current_menu to the end
		if current_menu - 1 < 0:
			current_menu = groups.size()-1
		else:
			current_menu -= 1

		groups[current_menu].play("sub_menu/fade_in_from_left")
		tab_groups[current_menu].fade_in()


func next_tab_sfx() -> void:
	audio_stream_player.pitch_scale = 1
	audio_stream_player.play()


func prev_tab_sfx() -> void:
	audio_stream_player.pitch_scale = 0.8
	audio_stream_player.play()
