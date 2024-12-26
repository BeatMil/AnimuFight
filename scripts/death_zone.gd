extends Node2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("hitted"):
		print("===deathzone===")
		if body.is_on_floor():
			body.hitted(
			self,
			true,
			Vector2.ZERO,
			0,
			0,
			0,
			Vector2(300, 0.5),
			9999,
			Enums.Attack.UNBLOCK,
			Vector2(0.8, 0.8),
			0
			)
