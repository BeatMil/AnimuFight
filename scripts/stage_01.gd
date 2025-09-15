extends Node2D


@onready var animation_player: AnimationPlayer = $MangoBossSitBanana/AnimationPlayer
@onready var area_lock_player: AnimationPlayer = $AreaLockPlayer
@onready var enemy_spawner_new: Node2D = $EnemySpawnerNew


func _ready() -> void:
	# Set camera lock
	# get_node_or_null("Player/Camera").set_screen_lock(0, 1920, 135, 1129)
	get_node_or_null("Player/Camera").set_screen_lock(-10000000, 10000000, -10000000, 1000)
	# get_node_or_null("Player/Camera").set_screen_lock(-1920, 1920, -10000000, 1000)
	get_node_or_null("Player/Camera").set_zoom(Vector2(1,1))
	area_lock_player.play("RESET")
	enemy_spawner_new.is_active = false

	Settings.current_stage = "res://scenes/stage_01.tscn"

	# Player ost
	# music_player.play("stage01_track_copyright")
	# music_player.play("stage01_track")

	# Attack!
	AttackQueue.start_queue_timer()
	# AttackQueue.stop_queue_timer()

	# if enemy_spawner_new.phase >= 5:
	# 	_shoot_up_house()


func _on_market_green_banana_fly() -> void:
	animation_player.play("shock")


func _on_area_1_lock_trigger_body_entered(_body: Node2D) -> void:
	area_lock_player.play("1_in")
	get_node_or_null("Player/Camera").set_screen_lock(-1920, 1920, -10000000, 1000)
	enemy_spawner_new.is_active = true
