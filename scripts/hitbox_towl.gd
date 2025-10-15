extends "res://scripts/hitbox.gd"

@onready var throw_break_timer: Timer = $ThrowBreakTimer

var target


func _on_area_2d_body_entered(body: Node2D) -> void:
	# Put player in THROW_BREAKABLE state
	if body.has_method("hitted"):
		target = body
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
	throw_break_timer.start()


func _on_throw_break_timer_timeout() -> void:
	if target.state not in [17, 5]: #THROW_BREAKABLE:
		return
	target.hitted(get_parent(),
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
