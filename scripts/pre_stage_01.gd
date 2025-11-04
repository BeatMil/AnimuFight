extends Node2D


const DEBRIS = preload("res://nodes/debris.tscn")
const DEBRIS_UP = preload("res://nodes/debris_upward.tscn")
const LIGHT_PARTICLE = preload("res://nodes/hitsparks/light_particle.tscn")
const BOSS_BOUNCE_SFX = preload("res://media/sfxs/unequip01.wav")

@onready var black_bar_cutscene: Node2D = $CanvasLayer/BlackBarCutscene
@onready var debris_animation_player: AnimationPlayer = $DebrisArea2D/AnimationPlayer
@onready var debris_area_2d: Area2D = $DebrisArea2D
@onready var no_door: Sprite2D = $DebrisArea2D/NoDoor
@onready var player: CharacterBody2D = $Player
@onready var music_player: AnimationPlayer = $MusicPlayer
@onready var animation_player: AnimationPlayer = $Background/AnimationPlayer
@onready var wind_sound_player: AnimationPlayer = $Background/WindSoundPlayer
@onready var bounce_to_left: Area2D = $BounceToLeft
@onready var bounce_to_right: Area2D = $BounceToRight
@onready var spawn_debris_fx: Node = $SpawnDebrisFX
@onready var boss_bounce_player: AudioStreamPlayer = $BounceBossBack/BossBouncePlayer
@onready var sky_animation_player: AnimationPlayer = $ParallaxBackground/SkyBackground/AnimationPlayer
@onready var enemy_spawner_new: Node2D = $EnemySpawnerNew
@onready var light_player: AnimationPlayer = $Lights/AnimationPlayer
@onready var topLight_area_2d: Area2D = $Lights/topLight/Area2D
const STAGE_01 = preload("uid://cijpe5mfa2ffb")
@onready var restart_menu: Control = $CanvasLayer/RestartMenu
@onready var heli_player: AnimationPlayer = $HeliPlayer
@onready var audio_stream_player: AudioStreamPlayer = $HeliPlayer/AudioStreamPlayer

var boss

signal shoot_up_house


func _ready() -> void:
	connect("shoot_up_house", _shoot_up_house)
	# Set camera lock
	CameraManager.enable_all_camera()
	CameraManager.player = player
	CameraManager.make_current(0)
	# CameraManager.zoom_permanent(Vector2(1.9, 0.9))
	CameraManager.set_zoom(Vector2(1, 1))
	CameraManager.set_screen_lock(0, 1940, 135, 1029)
	CameraManager.set_zoom(Vector2.ONE)
	print("_ready: _pre_stage_01.gd")
	# CameraManager.set_screen_lock(0, 1920, 0, 1000)
	# get_node_or_null("Player/Camera").set_zoom(Vector2(1,1))

	player.ded.connect(_player_ded)

	Settings.current_stage = "res://scenes/pre_stage01.tscn"

	# Player ost
	music_player.play("stage01_track_copyright")
	# music_player.play("stage01_track")

	# Attack!
	AttackQueue.start_queue_timer()
	# AttackQueue.stop_queue_timer()

	# if enemy_spawner_new.phase >= 5:
	# 	_shoot_up_house()


func _player_ded() -> void:
	if Settings.checkpoint >= 8 and player.global_position.y > 1600:
		# player falls to deathzone
		Settings.checkpoint = 0
		get_tree().change_scene_to_packed(STAGE_01)
	else:
		restart_menu.open_menu()


func _shoot_up_house() -> void:
	animation_player.play("shoot_up")
	wind_sound_player.play("wind_sound")
	sky_animation_player.play("sky_down")
	CameraManager.make_current(0)
	CameraManager.set_screen_lock(-200, 2200, 0, 1400)
	CameraManager.set_zoom(Vector2(0.8, 0.8))
	for pos in spawn_debris_fx.get_children():
		var debris = DEBRIS_UP.instantiate()
		debris.position = pos.position
		add_child(debris)
	# get_node_or_null("Player/Camera").set_screen_lock(-20000, 220000, -100000, 300000)
	# get_node_or_null("Player/Camera").zoom_permanent(Vector2(-0.8, -0.8))


func _on_debris_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if get_node_or_null("DebrisArea2D/NoDoor"):
			body._push_x_direct_old(-700)
			var debris = DEBRIS.instantiate()
			debris.position = $DebrisMarker2D.position
			add_child(debris)
			debris_animation_player.play("break_in")
			await get_tree().create_timer(0.1).timeout
			no_door.queue_free()
		else:
			body._push_x_direct_old(-600)


func _on_bounce_to_left_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if !body.is_jump_spawn:
			body._push_direct(Vector2(-200, -500))
			body.is_jump_spawn = true



func _on_bounce_to_right_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if !body.is_jump_spawn:
			body._push_direct(Vector2(200, -500))
			body.is_jump_spawn = true


func _on_helicop_spawn_body_entered(body: Node2D) -> void:
	print_rich("[color=brown][b]HeliSpawn![/b][/color]")
	if body.is_in_group("enemy"):
		body.is_jump_spawn = true
		var tween = get_tree().create_tween()
		tween.tween_property(body, "position", Vector2(1900, 288), 1).set_trans(Tween.TRANS_CUBIC)


func _on_bounce_boss_back_body_entered(body: Node2D) -> void:
	if body.is_in_group("boss"):
		if body.hp_bar.get_hp() <= 0:
			return
		boss_bounce_player.stream = BOSS_BOUNCE_SFX
		boss_bounce_player.pitch_scale = randf_range(0.8, 1.2)
		boss_bounce_player.play()

		body.animation_player.play("idle")

		if body.position.x > 900:
			body._push_direct(Vector2(-200, -200))
		else:
			body._push_direct(Vector2(200, -200))


func _on_area_2d_body_entered(_body: Node2D) -> void:
	var part = LIGHT_PARTICLE.instantiate()
	part.position = light_player.get_parent().position
	add_child(part)
	light_player.play("light_breaks")
	topLight_area_2d.queue_free()
	# topLight_area_2d.monitoring = false


func boss_defeated() -> void:
	player.is_controllable = false
	player.move_hud_away()
	black_bar_cutscene.enable()
	heli_player.play("kick_player")
	print("play boss kick player")


func _on_heli_area_2d_body_entered(body: Node2D) -> void:
	body.hitted(
	self,
	body.sprite_2d.flip_h,
	Vector2(4200, -200),
	1,
	0.5,
	2,
	Vector2(10, 0.1),
	0,
	Enums.Attack.UNBLOCK
	)
	audio_stream_player.play()


func hitlag(_amount: float = 0.3) -> void:
	if _amount:
		set_physics_process(false)
		await get_tree().create_timer(_amount).timeout
		set_physics_process(true)
