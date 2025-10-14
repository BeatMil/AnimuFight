extends Node2D


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
const DSGN_IMPT_MELEE_HOMERUNNER_HY_PC_002 = preload("uid://cv0rvmws6gsn3")


var pitch_scale = 1


func hitlag(_amount: float = 0.3) -> void:
	if _amount:
		set_physics_process(false)
		await get_tree().create_timer(_amount).timeout
		set_physics_process(true)


func _ready() -> void:
	audio_stream_player_2d.pitch_scale = pitch_scale
	animation_player.play("move_down")
	audio_stream_player_2d.play()


func hit_ground() -> void:
	CameraManager.start_screen_shake(20, 0.2)
	audio_stream_player_2d.stream = DSGN_IMPT_MELEE_HOMERUNNER_HY_PC_002
	audio_stream_player_2d.pitch_scale = randf_range(0.5, 1.5)
	audio_stream_player_2d.play()


func _on_hitbox_body_entered(body: Node2D) -> void:
	body.hitted(
		self,
		body.sprite_2d.flip_h,
		Vector2(300, -50),
		1,
		0.5,
		2,
		Vector2(10, 0.1),
		3,
		Enums.Attack.MOVE
	)
