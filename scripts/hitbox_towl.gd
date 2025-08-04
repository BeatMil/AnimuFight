extends "res://scripts/hitbox.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("hitbox towl desu!")
	pass
	# timer.wait_time = time_left_before_queue_free
	# timer.start()
	# _set_collision_hit_player()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("hitted"):
		body.hitted(get_parent(),
		get_parent().is_face_right,
		push_power_ground,
		push_type_ground,
		hitlag_amount_ground,
		hitstun_amount_ground,
		screenshake_amount,
		damage,
		type,
		zoom,
		zoom_duration,
		slow_mo_on_block
		)
		_on_timer_timeout()
	await get_tree().create_timer(0.5).timeout
	if body.state not in [17, 5]: #THROW_BREAKABLE:
		return
	body.hitted(get_parent(),
	get_parent().is_face_right,
	push_power_ground,
	push_type_ground,
	hitlag_amount_ground,
	hitstun_amount_ground,
	screenshake_amount,
	damage,
	Enums.Attack.NORMAL,
	zoom,
	zoom_duration,
	slow_mo_on_block
	)
	_play_hit_random_pitch()
