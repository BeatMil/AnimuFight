extends Node2D

@onready var area_2d: Area2D = $FlowerPot/Area2D
@onready var break_flower_pot: Node2D = $BreakFlowerPot
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var is_face_right = false


func _ready() -> void:
	for i in break_flower_pot.get_children():
		i.gravity_scale = 0


func hitted(
	_attacker: Object,
	is_push_to_the_right: bool,
	push_power: Vector2 = Vector2(20, 0),
	push_type: int = 0,
	hitlag_amount: float = 0,
	hitstun_amount: float = 0.5,
	_screenshake_amount: Vector2 = Vector2(10, 0.1),
	_damage: int = 1,
	_type: int = 0,
	_zoom: Vector2 = Vector2(0, 0),
	_zoom_duration: float = 0.1,
	slow_mo_on_block: Vector2 = Vector2(0, 0)
	) -> void:
	pass


func hitlag(_amount: float = 0.3) -> void:
	if _amount:
		set_physics_process(false)
		await get_tree().create_timer(_amount).timeout
		set_physics_process(true)


func pot_break() -> void:
	for i in break_flower_pot.get_children():
		i.gravity_scale = 3
		match i.name:
			"TL":
				i.apply_torque(10000)
				i.apply_impulse(Vector2(-1000, -1000))
			"TR":
				i.apply_torque(10000)
				i.apply_impulse(Vector2(1000, -1000))
			"BL":
				i.apply_torque(10000)
				i.apply_impulse(Vector2(-1000, 1000))
			"BR":
				i.apply_torque(10000)
				i.apply_impulse(Vector2(-1000, 1000))


func _on_trigger_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		animation_player.play("fall")
		# animation_player.play("fall", -1, 0.5)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.state in [15, 16]:
		area_2d.collision_mask = 0b00000000000000000000
		return

	animation_player.stop()
	# break_flower_pot.position = body.position + Vector2(0, -300)
	break_flower_pot.visible = true
	pot_break()
