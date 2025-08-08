extends Node2D


const JUCTION_PARTICLE = preload("res://nodes/hitsparks/juction_particle.tscn")
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var object_in_box = []


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
		if body not in object_in_box:
			object_in_box.append(body)
		else:
			return
		body.hitted(
			self,
			body.sprite_2d.flip_h,
			Vector2(20, 0),
			0,
			0.5,
			2,
			Vector2(10, 0.1),
			2,
			Enums.Attack.UNBLOCK
		)
		ObjectPooling.spawn_juction_glass(body.position)
		animation_player.stop()
		animation_player.play("spark")


func _on_area_2d_body_exited(body: Node2D) -> void:
	object_in_box.erase(body)
