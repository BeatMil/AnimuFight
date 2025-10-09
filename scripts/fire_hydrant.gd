extends Node2D


@onready var animation_player: AnimationPlayer = $AnimationPlayer


func hitlag(_amount: float = 0.3) -> void:
	if _amount:
		set_physics_process(false)
		await get_tree().create_timer(_amount).timeout
		set_physics_process(true)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.state in [
	body.States.WALL_BOUNCED,
	body.States.BOUNCE_STUNNED,
	body.States.THROWN
	]:
		body.hitted(
			self,
			body.sprite_2d.flip_h,
			Vector2(50, -200),
			1,
			0.1,
			2,
			Vector2(10, 0.1),
			2,
			Enums.Attack.UNBLOCK
		)
		animation_player.stop()
		animation_player.play("push_water")
		ObjectPooling.spawn_fire_hydrant_spark(self.position)
	
