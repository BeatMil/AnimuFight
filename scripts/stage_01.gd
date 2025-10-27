extends Node2D

@onready var check_points: Node = $CheckPoints
@onready var restart_menu: Control = $CanvasLayer/RestartMenu
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
@onready var bridge_player: AnimationPlayer = $Area4/BridgePlayer


@onready var boss_01: CharacterBody2D = $Area6/Boss01
@onready var boss_02: CharacterBody2D = $Area6/Boss02
@onready var wait_boss_platform: StaticBody2D = $Area6/WaitBossPlatform
@onready var shiny: Node2D = $Area6/Shiny
@onready var black_bar_cutscene: Node2D = $CanvasLayer/BlackBarCutscene
@onready var boss_intro_trigger: Area2D = $Area6/BossIntroTrigger
@onready var area_6_spawner: Node2D = $Area6/Area6Spawner
@onready var player_skip_pos: Marker2D = $Area6/PlayerSkipPos
@onready var boss_skip_pos: Marker2D = $Area6/BossSkipPos
var boss_intro_tween: Tween
var is_in_boss_intro = false
@onready var area_6_player: AnimationPlayer = $Area6/Area6Player
@onready var heli_shot_pos: Node2D = $Area6/HeliShotPos
const HELI_SPEAR = preload("uid://4hm7nxb8bsll")
@onready var helicopter: Sprite2D = $Area6/Helicopter
@export var enemy_to_spawn: Array[Resource]
@onready var enemy_backup: Node = $Area6/EnemyBackup
@onready var animu_fast_fx_whole_screen: Node2D = $CanvasLayer/AnimuFastFxWholeScreen
@onready var white_animation_player: AnimationPlayer = $Area6/WhiteEffect/AnimationPlayer
@onready var final_hit_audio_player: AudioStreamPlayer = $Area6/FinalHitAudioPlayer

@onready var music_player: AnimationPlayer = $MusicPlayer
@onready var market_green: Node2D = $MarketGreen

func hitlag(_amount: float = 0.3) -> void:
	pass
	# if _amount:
	# 	set_physics_process(false)
	# 	await get_tree().create_timer(_amount).timeout
	# 	set_physics_process(true)


func intro() -> void:
	player.is_controllable = false
	player.set_physics_process(false)
	player.play_animation("fall")
	event_player.play("intro")
	await get_tree().create_timer(2).timeout
	# Player ost
	music_player.play("PoundThePavement")
	player.play_animation("idle")
	player.is_controllable = true
	player.set_physics_process(true)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or \
		event.is_action_pressed("ui_accept") or event.is_action_pressed("pause"):
		if is_in_boss_intro:
			_skip_boss_intro()


func _ready() -> void:
	# Set camera lock
	# get_node_or_null("Player/Camera").set_screen_lock(0, 1920, 135, 1129)
	# get_node_or_null("Player/Camera").set_screen_lock(-10000000, 10000000, -10000000, 1000)
	player.ded.connect(_player_ded)

	CameraManager.enable_all_camera()
	CameraManager.set_zoom(Vector2.ONE)
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

	boss_02.call_heli.connect(boss_call_heli)
	boss_02.call_backup.connect(boss_call_backup)
	boss_02.boss_defeated.connect(boss_defeated)
	boss_02.set_physics_process(false)
	boss_02.visible = false

	Settings.current_stage = "res://scenes/stage_01.tscn"

	enemy_spawner_new.area_done.connect(_lift_wall_area1)
	area_3_spawner.area_done.connect(_lift_wall_area1)
	area_4_spawner.area_done.connect(_lift_wall_area1)
	area_5_spawner.area_done.connect(_lift_wall_area1)
	area_6_spawner.area_done.connect(_boss_second_time)

	Engine.time_scale = 1

	if Settings.checkpoint <= 0:
		intro()
	else:
		player.position = check_points.get_children()[Settings.checkpoint].position
		music_player.play("PoundThePavement")


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
	market_green.set_active(true)
	bridge_player.play("bridge")


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
	Settings.checkpoint = 1


func _mango_boss_down() -> void:
	area_lock_player.play("RESET")
	CameraManager.pos_lock_to_player()


func _on_area_3_lock_trigger_body_entered(_body: Node2D) -> void:
	area_lock_player.play("3_in")
	CameraManager.set_screen_lock(3824, 6380, -10000000, 1000)
	area_3_spawner.is_active = true
	area_3_lock_trigger.queue_free()
	Settings.checkpoint = 2
	market_green.set_active(false)


func _on_area_4_lock_trigger_body_entered(_body: Node2D) -> void:
	bridge_player.play("RESET")
	area_lock_player.play("4_in")
	CameraManager.set_screen_lock(6400, 8800, -10000000, 1000)
	area_4_spawner.is_active = true
	area_4_lock_trigger.queue_free()
	Settings.checkpoint = 3


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
	Settings.checkpoint = 4


func _on_boss_intro_trigger_body_entered(body: Node2D) -> void:
	music_player.stop()
	Settings.checkpoint = 5
	boss_intro_trigger.queue_free()
	area_lock_player.play("6_in")
	# boss_01.queue_free()
	# _boss_second_time()
	# return
	is_in_boss_intro = true
	body.is_controllable = false
	if body.state == 10: # AIR state
		body.velocity = Vector2.ZERO
		await get_tree().create_timer(0.3).timeout

	player.move_hud_away()
	black_bar_cutscene.enable()
	var delta = get_physics_process_delta_time()
	boss_intro_tween = create_tween()
	boss_intro_tween.tween_callback(body.play_animation.bind("walk"))
	boss_intro_tween.tween_method(body._move_right, delta, delta, 0.6)
	boss_intro_tween.tween_callback(body.play_animation.bind("idle"))
	boss_intro_tween.tween_callback(wait_boss_platform.queue_free)
	boss_intro_tween.tween_callback(boss_01.meteo_crash)
	boss_intro_tween.tween_interval(1.2)
	boss_intro_tween.tween_callback(body.play_animation.bind("dodge"))
	boss_intro_tween.tween_interval(0.18)
	boss_intro_tween.tween_callback(shiny.queue_free)
	boss_intro_tween.tween_interval(0.8)
	boss_intro_tween.tween_callback(body.play_animation.bind("EWGF"))
	boss_intro_tween.tween_interval(0.5)
	boss_intro_tween.tween_callback(body.play_animation.bind("EWGF"))
	boss_intro_tween.tween_interval(0.5)
	boss_intro_tween.tween_callback(body.play_animation.bind("EWGF"))
	boss_intro_tween.tween_interval(0.5)
	boss_intro_tween.tween_callback(body.play_animation.bind("wave_dash"))
	boss_intro_tween.tween_interval(0.1)
	boss_intro_tween.tween_callback(body.play_animation.bind("EWGF"))
	boss_intro_tween.tween_interval(0.3)
	boss_intro_tween.tween_callback(body.play_animation.bind("jin1+2"))
	boss_intro_tween.tween_interval(0.8)
	boss_intro_tween.tween_callback(body.play_animation.bind("air_throw"))
	boss_intro_tween.tween_interval(1.0)
	boss_intro_tween.tween_callback(body.play_animation.bind("dash"))
	boss_intro_tween.tween_interval(0.3)
	boss_intro_tween.tween_callback(body.set_flip_h.bind(true))
	boss_intro_tween.tween_callback(body.play_animation.bind("lp1"))
	boss_intro_tween.tween_interval(0.2)
	boss_intro_tween.tween_callback(body.play_animation.bind("lp2"))
	boss_intro_tween.tween_interval(0.3)
	boss_intro_tween.tween_callback(body.play_animation.bind("lp3"))
	boss_intro_tween.tween_interval(0.3)
	boss_intro_tween.tween_callback(body.play_animation.bind("wave_dash"))
	boss_intro_tween.tween_callback(music_player.play.bind("HighTechDuel"))
	boss_intro_tween.tween_interval(0.3)
	boss_intro_tween.tween_callback(body.play_animation.bind("ground_grab"))
	boss_intro_tween.tween_callback(Input.action_press.bind("left"))
	boss_intro_tween.tween_interval(0.8)
	boss_intro_tween.tween_callback(Input.action_release.bind("left"))
	boss_intro_tween.tween_interval(0.5)
	boss_intro_tween.tween_callback(black_bar_cutscene.disable)
	boss_intro_tween.tween_callback(player.move_hud_back)
	boss_intro_tween.tween_callback(CameraManager.set_screen_lock.bind(13317, 15458, -10000000, 1000))
	boss_intro_tween.tween_callback(player.set_is_controllable.bind(true))
	boss_intro_tween.tween_callback(boss_01.set_notarget.bind(false))
	boss_intro_tween.tween_callback(boss_01.set_is_controllable.bind(true))
	boss_intro_tween.tween_callback(boss_01.set_attack_timer_bool.bind(true))
	boss_intro_tween.tween_callback(boss_01.set_attack_timer_bool.bind(true))
	boss_intro_tween.tween_callback(set_is_boss_intro.bind(false))


func _boss01_next_phase_emitted() -> void:
	area_6_spawner.is_active = true


func set_is_boss_intro(value: bool) -> void:
	is_in_boss_intro = value


func _skip_boss_intro() -> void: ## T^T
	music_player.play("HighTechDuel")
	is_in_boss_intro = false
	if boss_intro_tween:
		boss_intro_tween.kill()
	black_bar_cutscene.disable()
	player.move_hud_back()
	if shiny:
		shiny.queue_free()
	if wait_boss_platform:
		wait_boss_platform.queue_free()
	boss_01.position = boss_skip_pos.position
	player.position = player_skip_pos.position
	player.set_is_controllable(true)
	boss_01.set_notarget(false)
	boss_01.set_is_controllable(true)
	boss_01.set_attack_timer_bool(true)
	boss_01.animation_player.play("idle")
	boss_01.hp_bar.set_hp(40)
	CameraManager.set_screen_lock(13317, 15458, -10000000, 1000)


func boss_call_heli() -> void:
	area_6_player.stop()
	area_6_player.play("heli_attack")
	CameraManager.zoom(Vector2(-0.15, -0.15), 5)
	var pitch = 1
	for child in heli_shot_pos.get_children():
		ObjectPooling.spawn_heli_bomb_warning(child.global_position, pitch)
		pitch += 0.1
		await get_tree().create_timer(0.1).timeout
	await get_tree().create_timer(1).timeout
	pitch = 1
	for child in heli_shot_pos.get_children():
		spawn_heli_spear(child.global_position+Vector2(0,-1000), pitch)
		pitch += 0.1
		await get_tree().create_timer(0.18).timeout


func boss_call_backup() -> void:
	area_6_player.stop()
	area_6_player.play("heli_attack")
	CameraManager.zoom(Vector2(-0.15, -0.15), 5)
	spawn_random_enemy()


func spawn_random_enemy() -> void:
	enemy_to_spawn.shuffle()

	var offset = Vector2(0, -1000)
	var e = enemy_to_spawn[0].instantiate()
	e.position = heli_shot_pos.get_children()[1].global_position + offset
	e.hp = 10
	e.block_rate = 1
	e.target = player

	await get_tree().create_timer(2).timeout
	enemy_backup.add_child(e)

	var e1 = enemy_to_spawn[1].instantiate()
	e1.position = heli_shot_pos.get_children()[5].global_position + offset
	e1.target = player
	e1.hp = 10
	e1.block_rate = 1
	await get_tree().create_timer(0.5).timeout
	enemy_backup.add_child(e1)


func _boss_second_time() -> void:
	if shiny:
		shiny.queue_free()
	if wait_boss_platform:
		wait_boss_platform.queue_free()
	CameraManager.set_screen_lock(13317, 15458, -10000000, 1000)
	boss_02.set_physics_process(true)
	boss_02.visible = true
	ObjectPooling.spawn_attack_type_indicator(1, player.position)
	ObjectPooling.spawn_attack_type_indicator(1, player.position-Vector2(-100, 0))
	ObjectPooling.spawn_attack_type_indicator(1, player.position-Vector2(100, 0))
	boss_02.meteo_crash()
	boss_02.set_attack_timer_bool(true)


func spawn_heli_spear(pos, pitch) -> void:
	var hitspark = HELI_SPEAR.instantiate()
	hitspark.position = pos
	hitspark.pitch_scale = pitch
	get_tree().current_scene.add_child(hitspark)


func boss_defeated() -> void:
	final_hit_audio_player.play()
	white_animation_player.play("in")
	CameraManager.zoom(Vector2(0.5, 0.5), 2)
	animu_fast_fx_whole_screen.visible = true
	ObjectPooling.spawn_ground_spark_2(player.position)
	for child in enemy_backup.get_children():
		child._set_state(0)
		child.hitted(
		self,
		true,
		Vector2(0, -500),
		1,
		0.5,
		2,
		Vector2(10, 0.1),
		10000,
		Enums.Attack.UNBLOCK
		)

		await get_tree().create_timer(0.1).timeout

		child.hitted(
		self,
		true,
		Vector2(0, -500),
		1,
		0.5,
		2,
		Vector2(10, 0.1),
		10000,
		Enums.Attack.UNBLOCK
		)
	
	await get_tree().create_timer(2*Engine.time_scale).timeout
	white_animation_player.play("out")
	music_player.play("chihuahua")
	animu_fast_fx_whole_screen.visible = false
	Engine.time_scale = 1
	var tween = get_tree().create_tween().set_loops()
	tween.tween_callback(ObjectPooling.spawn_ground_spark_2.bind(player.position)).set_delay(1.0)


func _player_ded() -> void:
	restart_menu.open_menu()
