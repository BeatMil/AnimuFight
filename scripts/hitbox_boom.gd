extends "res://scripts/hitbox.gd"

var boom_speed = 2000


func _ready() -> void:
	super._ready()
	active_frame = 1000
	active_frame_timer.wait_time = active_frame
	active_frame_timer.start()



func _physics_process(delta: float) -> void:
	move_local_x(boom_speed * delta)
