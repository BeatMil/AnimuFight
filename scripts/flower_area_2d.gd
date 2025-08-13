extends "res://scripts/hitbox.gd"


func _ready() -> void:
	super._ready()
	active_frame = 10
	push_power_ground = Vector2(800, -100)
	push_type_ground = Enums.Push_types.KNOCKDOWN
	push_power_air = Vector2(800, -100)
	push_type_air = Enums.Push_types.KNOCKDOWN
	hitlag_amount_ground = 0.3
	hitlag_amount_air = 0.3
	hitstun_amount_ground = 0.6
	hitstun_amount_air = 0.6
	screenshake_amount = Vector2(10, 0.1)
	damage = 3
	type = Enums.Attack.NORMAL
	zoom = Vector2.ZERO
	zoom_duration = 0
	is_stay = true

	hit_noise = preload("res://media/sfxs/HitStone2.wav")
