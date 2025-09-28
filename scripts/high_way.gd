extends Node2D
@onready var area_2d: Area2D = $Area2D


func hitlag(_amount: float = 0.3) -> void:
	if _amount:
		set_physics_process(false)
		await get_tree().create_timer(_amount).timeout
		set_physics_process(true)


func disable_area2d() -> void:
	area_2d.queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("highway: ", body.name)
	body.hitted(
	self,
	body.sprite_2d.flip_h,
	Vector2(20, 0),
	1,
	0.5,
	2,
	Vector2(10, 0.1),
	10000,
	Enums.Attack.UNBLOCK
	)
