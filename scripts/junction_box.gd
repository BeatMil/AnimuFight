extends Node2D

@export var amount_to_explode = 100

@onready var area_2d: Area2D = $Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var object_in_box = []
var total_shock = 0

signal explode

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
		total_shock += 1
		if total_shock >= amount_to_explode:
			ObjectPooling.spawn_hit_spark_cool(position)
			animation_player.play("explode")
			area_2d.queue_free()
			CameraManager.start_screen_shake(20, 1.0)
			await get_tree().create_timer(1).timeout
			emit_signal("explode")
		else:
			ObjectPooling.spawn_juction_glass(body.position)
			animation_player.stop()
			animation_player.play("spark")


func _on_area_2d_body_exited(body: Node2D) -> void:
	object_in_box.erase(body)
