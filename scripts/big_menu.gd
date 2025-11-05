extends Control


@onready var sub_groups: Control = $SubGroups
@onready var sub_game_menu: Control = $SubGroups/SubGameMenu
var groups = []
@onready var tab_container: HBoxContainer = $NavBarBackground/TabContainer
var tab_groups = []


var current_menu: int = 0

var stretch_ratio = 2


func _ready() -> void:
	groups = sub_groups.get_children()
	tab_groups = tab_container.get_children()
	await get_tree().create_timer(1).timeout
	groups[current_menu].play("sub_menu/fade_in_from_left")
	var tween = get_tree().create_tween()
	tween.tween_property(tab_groups[current_menu], "size_flags_stretch_ratio", stretch_ratio, 0.2)
	print("fade in from left")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_next_tab"):
		groups[current_menu].play("sub_menu/fade_out_to_left")
		var tween = get_tree().create_tween()
		tween.tween_property(tab_groups[current_menu], "size_flags_stretch_ratio", 1.0, 0.1)
		

		# Bring current_menu back to start
		if current_menu + 1 >= groups.size():
			current_menu = 0
		else:
			current_menu += 1

		groups[current_menu].play("sub_menu/fade_in_from_right")
		tween.tween_property(tab_groups[current_menu], "size_flags_stretch_ratio", stretch_ratio, 0.1)
	if event.is_action_pressed("ui_prev_tab"):
		groups[current_menu].play("sub_menu/fade_out_to_right")
		var tween = get_tree().create_tween()
		tween.tween_property(tab_groups[current_menu], "size_flags_stretch_ratio", 1.0, 0.1)

		# Bring current_menu to the end
		if current_menu - 1 < 0:
			current_menu = groups.size()-1
		else:
			current_menu -= 1

		groups[current_menu].play("sub_menu/fade_in_from_left")
		tween.tween_property(tab_groups[current_menu], "size_flags_stretch_ratio", stretch_ratio, 0.1)
