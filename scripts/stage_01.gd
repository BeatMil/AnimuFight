extends Node2D


@onready var animation_player: AnimationPlayer = $MangoBossSitBanana/AnimationPlayer
@onready var area_lock_player: AnimationPlayer = $AreaLockPlayer
@onready var enemy_spawner_new: Node2D = $EnemySpawnerNew
# @onready var transition_camera: Camera2D = $Cameras/TransitionCamera
@onready var player: CharacterBody2D = $Player
@onready var area_1_lock_trigger: Area2D = $Area1LockTrigger
const MANGO_BOSS = preload("res://nodes/mango_boss.tscn")


func _ready() -> void:
	# Set camera lock
	# get_node_or_null("Player/Camera").set_screen_lock(0, 1920, 135, 1129)
	# get_node_or_null("Player/Camera").set_screen_lock(-10000000, 10000000, -10000000, 1000)
	CameraManager.set_screen_lock(-10000000, 10000000, -10000000, 1000)
	CameraManager.player = player
	CameraManager.make_current(0)
	# get_node_or_null("Player/Camera").set_screen_lock(-1920, 1920, -10000000, 1000)
	# get_node_or_null("Player/Camera").set_zoom(Vector2(1,1))
	area_lock_player.play("RESET")
	enemy_spawner_new.is_active = false

	Settings.current_stage = "res://scenes/stage_01.tscn"

	enemy_spawner_new.area1_done.connect(_lift_wall_area1)

	# Player ost
	# music_player.play("stage01_track_copyright")
	# music_player.play("stage01_track")

	# Attack!
	AttackQueue.start_queue_timer()
	# AttackQueue.stop_queue_timer()

	# if enemy_spawner_new.phase >= 5:
	# 	_shoot_up_house()


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
	animation_player.play("shock")
	area_lock_player.play("2_in")
	CameraManager.pos_lock($MarketCamPos.position)

	var mango_boss = MANGO_BOSS.instantiate()
	mango_boss.position = Vector2(2888, 320)
	mango_boss.target = player
	mango_boss.hp = 80
	mango_boss.mango_boss_down.connect(_mango_boss_down)
	add_child(mango_boss)


func _mango_boss_down() -> void:
	area_lock_player.play("RESET")
	CameraManager.pos_lock_to_player()
