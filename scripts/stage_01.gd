extends Node2D


@onready var animation_player: AnimationPlayer = $MangoBossSitBanana/AnimationPlayer
@onready var area_lock_player: AnimationPlayer = $AreaLockPlayer
# @onready var transition_camera: Camera2D = $Cameras/TransitionCamera
@onready var player: CharacterBody2D = $Player
@onready var area_1_lock_trigger: Area2D = $Area1LockTrigger
@onready var area_3_lock_trigger: Area2D = $Area3/Area3LockTrigger
const MANGO_BOSS = preload("res://nodes/mango_boss.tscn")
@onready var mango_boss_sit_banana: Sprite2D = $MangoBossSitBanana
@onready var enemy_spawner_new: Node2D = $EnemySpawnerNew
@onready var area_3_spawner: Node2D = $Area3/Area3Spawner
@onready var event_player: AnimationPlayer = $EventPlayer
@onready var high_way: Node2D = $Area3/HighWay

@onready var area_4_lock_trigger: Area2D = $Area4/Area4LockTrigger
@onready var area_4_spawner: Node2D = $Area4/Area4Spawner
const BANANA_FLY = preload("uid://dmjg7bqnvd1dk")
@onready var audio_stream_player: AudioStreamPlayer = $Area4/PushPlayerBackUpArea2d/AudioStreamPlayer

@onready var area_5_lock_trigger: Area2D = $Area5/Area5LockTrigger
@onready var area_5_spawner: Node2D = $Area5/Area5Spawner


@onready var boss_01: CharacterBody2D = $Area6/Boss01
@onready var boss_02: CharacterBody2D = $Area6/Boss02
@onready var wait_boss_platform: StaticBody2D = $Area6/WaitBossPlatform
@onready var shiny: Node2D = $Area6/Shiny
@onready var black_bar_cutscene: Node2D = $CanvasLayer/BlackBarCutscene
@onready var boss_intro_trigger: Area2D = $Area6/BossIntroTrigger
@onready var area_6_spawner: Node2D = $Area6/Area6Spawner


func hitlag(_amount: float = 0.3) -> void:
	pass
	# if _amount:
	# 	set_physics_process(false)
	# 	await get_tree().create_timer(_amount).timeout
	# 	set_physics_process(true)


func _ready() -> void:
	# Set camera lock
	# get_node_or_null("Player/Camera").set_screen_lock(0, 1920, 135, 1129)
	# get_node_or_null("Player/Camera").set_screen_lock(-10000000, 10000000, -10000000, 1000)
	CameraManager.enable_all_camera()
	CameraManager.set_screen_lock(-10000000, 10000000, -10000000, 1000)
	CameraManager.player = player
	CameraManager.is_following_player = true
	CameraManager.make_current(0)
	# get_node_or_null("Player/Camera").set_screen_lock(-1920, 1920, -10000000, 1000)
	# get_node_or_null("Player/Camera").set_zoom(Vector2(1,1))
	area_lock_player.play("RESET")
	enemy_spawner_new.is_active = false
	area_3_spawner.is_active = false
	area_4_spawner.is_active = false
	area_5_spawner.is_active = false
	boss_01.is_controllable = false
	boss_01.is_notarget = true
	boss_01.attack_timer_stop()
	area_6_spawner.is_active = false
	boss_01.next_phase.connect(_boss01_next_phase_emitted)
	boss_02.set_physics_process(false)
	boss_02.visible = false

	Settings.current_stage = "res://scenes/stage_01.tscn"

	enemy_spawner_new.area_done.connect(_lift_wall_area1)
	area_3_spawner.area_done.connect(_lift_wall_area1)
	area_4_spawner.area_done.connect(_lift_wall_area1)
	area_5_spawner.area_done.connect(_lift_wall_area1)
	area_6_spawner.area_done.connect(_boss_second_time)

	# Player ost
	# music_player.play("stage01_track_copyright")
	# music_player.play("stage01_track")

	# Attack!
	AttackQueue.start_queue_timer()
	# AttackQueue.stop_queue_timer()

	# if enemy_spawner_new.phase >= 5:
	# 	_shoot_up_house()


func _on_junction_box_explode() -> void:
	high_way.play_explosion()


func _on_area_1_lock_trigger_body_entered(_body: Node2D) -> void:
	area_lock_player.play("1_in")
	CameraManager.set_screen_lock(-1920, 1750, -10000000, 1000)
	enemy_spawner_new.is_active = true
	area_1_lock_trigger.queue_free()


func _lift_wall_area1() -> void:
	area_lock_player.play("RESET")
	CameraManager.set_screen_lock(-10000000, 10000000, -10000000, 1000)
	# var tween = get_tree().create_tween()
	# tween.tween_property(transition_camera, "position", player.position, 0.2).set_trans(Tween.TRANS_SINE)
	# tween.tween_interval(0.2)
	# tween.tween_callback(player.get_camera().make_current)


func _on_market_green_banana_fly() -> void:
	area_lock_player.play("2_in")
	CameraManager.pos_lock($MarketCamPos.position)

	animation_player.play("shock")
	await animation_player.animation_finished

	var mango_boss = MANGO_BOSS.instantiate()
	mango_boss.position = mango_boss_sit_banana.position
	mango_boss.target = player
	mango_boss.hp = 80
	mango_boss.mango_boss_down.connect(_mango_boss_down)
	add_child(mango_boss)
	mango_boss_sit_banana.queue_free()


func _mango_boss_down() -> void:
	area_lock_player.play("RESET")
	CameraManager.pos_lock_to_player()


func _on_area_3_lock_trigger_body_entered(_body: Node2D) -> void:
	area_lock_player.play("3_in")
	CameraManager.set_screen_lock(3824, 6380, -10000000, 1000)
	area_3_spawner.is_active = true
	area_3_lock_trigger.queue_free()


func _on_area_4_lock_trigger_body_entered(_body: Node2D) -> void:
	area_lock_player.play("4_in")
	CameraManager.set_screen_lock(6400, 8800, -10000000, 1000)
	area_4_spawner.is_active = true
	area_4_lock_trigger.queue_free()


func _on_push_player_back_up_area_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
	audio_stream_player.stream = BANANA_FLY
	audio_stream_player.play()
	
	var tween = get_tree().create_tween()
	var new_pos = body.position + Vector2(-500, -500)
	tween.tween_property(body, "position", new_pos, 0.2).set_trans(Tween.TRANS_CUBIC)
	body.hitted(
	self,
	body.sprite_2d.flip_h,
	Vector2(0, 0),
	1,
	0.5,
	0.5,
	Vector2(10, 0.1),
	4,
	Enums.Attack.UNBLOCK
	)


func _on_area_5_lock_trigger_body_entered(_body: Node2D) -> void:
	area_lock_player.play("5_in")
	CameraManager.set_screen_lock(9610, 12644, -10000000, 1000)
	area_5_spawner.is_active = true
	area_5_lock_trigger.queue_free()


func _on_boss_intro_trigger_body_entered(body: Node2D) -> void:
	boss_intro_trigger.queue_free()
	body.is_controllable = false
	if body.state == 10: # AIR state
		body.velocity = Vector2.ZERO
		await get_tree().create_timer(0.3).timeout

	area_lock_player.play("6_in")
	player.move_hud_away()
	black_bar_cutscene.enable()
	var delta = get_physics_process_delta_time()
	var tween = create_tween()
	tween.tween_callback(body.play_animation.bind("walk"))
	tween.tween_method(body._move_right, delta, delta, 0.8)
	tween.tween_callback(body.play_animation.bind("idle"))
	tween.tween_callback(wait_boss_platform.queue_free)
	tween.tween_callback(boss_01.meteo_crash)
	tween.tween_interval(1.2)
	tween.tween_callback(body.play_animation.bind("dodge"))
	tween.tween_interval(0.18)
	tween.tween_callback(shiny.queue_free)
	tween.tween_interval(0.8)
	tween.tween_callback(body.play_animation.bind("EWGF"))
	tween.tween_interval(0.5)
	tween.tween_callback(body.play_animation.bind("EWGF"))
	tween.tween_interval(0.5)
	tween.tween_callback(body.play_animation.bind("EWGF"))
	tween.tween_interval(0.5)
	tween.tween_callback(body.play_animation.bind("wave_dash"))
	tween.tween_interval(0.1)
	tween.tween_callback(body.play_animation.bind("EWGF"))
	tween.tween_interval(0.3)
	tween.tween_callback(body.play_animation.bind("jin1+2"))
	tween.tween_interval(0.8)
	tween.tween_callback(body.play_animation.bind("air_throw"))
	tween.tween_interval(1.0)
	tween.tween_callback(body.play_animation.bind("dash"))
	tween.tween_interval(0.3)
	tween.tween_callback(body.set_flip_h.bind(true))
	tween.tween_callback(body.play_animation.bind("lp1"))
	tween.tween_interval(0.2)
	tween.tween_callback(body.play_animation.bind("lp2"))
	tween.tween_interval(0.3)
	tween.tween_callback(body.play_animation.bind("lp3"))
	tween.tween_interval(0.3)
	tween.tween_callback(body.play_animation.bind("wave_dash"))
	tween.tween_interval(0.3)
	tween.tween_callback(body.play_animation.bind("ground_grab"))
	tween.tween_callback(Input.action_press.bind("left"))
	tween.tween_interval(0.5)
	tween.tween_callback(Input.action_release.bind("left"))
	tween.tween_interval(0.5)
	tween.tween_callback(black_bar_cutscene.disable)
	tween.tween_callback(player.move_hud_back)
	tween.tween_callback(CameraManager.set_screen_lock.bind(13317, 15458, -10000000, 1000))
	tween.tween_callback(player.set_is_controllable.bind(true))
	tween.tween_callback(boss_01.set_notarget.bind(false))
	tween.tween_callback(boss_01.set_is_controllable.bind(true))
	tween.tween_callback(boss_01.set_attack_timer_bool.bind(true))


func _boss01_next_phase_emitted() -> void:
	area_6_spawner.is_active = true


func _boss_second_time() -> void:
	boss_02.set_physics_process(true)
	boss_02.visible = true
	ObjectPooling.spawn_attack_type_indicator(1, player.position)
	ObjectPooling.spawn_attack_type_indicator(1, player.position-Vector2(-100, 0))
	ObjectPooling.spawn_attack_type_indicator(1, player.position-Vector2(100, 0))
	boss_02.meteo_crash()
