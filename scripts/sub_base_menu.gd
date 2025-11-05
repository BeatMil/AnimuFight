extends Control


@onready var sub_menu_player: AnimationPlayer = $SubMenuPlayer


func play(anim_name: String) -> void:
	sub_menu_player.play(anim_name)
