extends "res://scripts/hitbox_lp.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = time_left_before_queue_free
	timer.start()
	_set_collision_hit_player()
