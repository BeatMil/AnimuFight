extends "res://scripts/player.gd"


signal block_success
signal dodge_success
signal throw_break_success


func _ready() -> void:
	super._ready()
	animation_player.animation_started.connect(anim_start)
	
	
func anim_start(anim_name: String) -> void:
	if anim_name in ["parry_success", "blockstunned"]:
		emit_signal("block_success")
	elif anim_name in ["dodge_success", "dodge_success_zoom"]:
		emit_signal("dodge_success")
	elif anim_name == "throw_break":
		emit_signal("throw_break_success")
