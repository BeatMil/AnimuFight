extends "res://scripts/hitbox.gd"


## detect both ground and player
func _set_collision_hit_player() -> void:
	area_2d.collision_mask = 0b00000000000000001001


## Spawn ground spark
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("ground"):
		get_parent().set_collision_normal()
		ObjectPooling.spawn_ground_spark(global_position, false)
	if body.has_method("hitted"):
		if body.is_on_floor():
			var facing = true
			if global_position.x > body.position.x:
				facing = false
			else:
				facing = true
			body.hitted(get_parent(),
			facing,
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
		else:
			body.hitted(get_parent(),
			get_parent().is_face_right,
			push_power_air,
			push_type_air,
			hitlag_amount_air,
			hitstun_amount_air,
			screenshake_amount,
			damage,
			type,
			zoom,
			zoom_duration,
			slow_mo_on_block
			)
		if body.state not in [
			body.States.BLOCK,
			body.States.PARRY,
			body.States.ARMOR,
			] and name != "HitboxTowl":
			_play_hit_random_pitch()
