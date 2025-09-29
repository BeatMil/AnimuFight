extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var area_2d: Area2D = $BigRectangle/Area2D
const GROUND_HIT = preload("uid://cpl7fyrbe36bv")
@onready var audio_stream_player_2: AudioStreamPlayer = $AudioStreamPlayer2


func hitlag(_amount: float = 0.3) -> void:
	if _amount:
		set_physics_process(false)
		await get_tree().create_timer(_amount).timeout
		set_physics_process(true)


func play_explosion() -> void:
	animation_player.play("explosion")


func disable_area2d() -> void:
	area_2d.queue_free()


func play_ground_hit2() -> void:
	audio_stream_player_2.stream = GROUND_HIT
	audio_stream_player_2.play()


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("highway: ", body.name)
	body.hitted(
	self,
	body.sprite_2d.flip_h,
	Vector2(1000, -200),
	1,
	0.5,
	2,
	Vector2(10, 0.1),
	10000,
	Enums.Attack.UNBLOCK
	)
	play_ground_hit2()
	animation_player.pause()
	await get_tree().create_timer(0.5).timeout
	animation_player.play()
