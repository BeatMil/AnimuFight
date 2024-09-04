extends "res://scripts/base_character.gd"


#############################################################
## Config
#############################################################
# var is_face_right:bool = true


func _physics_process(_delta: float) -> void:
	is_face_right = not sprite_2d.flip_h
	_z_index_equal_to_y()


func _ready() -> void:
	$Timer.start()
	_lp()


func _on_timer_timeout() -> void:
	if hp > 0:
		_lp()
