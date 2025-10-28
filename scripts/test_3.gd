extends Node2D

@onready var enemy: CharacterBody2D = $TestWallThrow/Enemy
@onready var enemy_2: CharacterBody2D = $TestWallThrow/Enemy2
@onready var player: CharacterBody2D = $Player


func test_wall_throw() -> void:
	var tween = get_tree().create_tween()
	tween.tween_callback(enemy.hitted.bind(
					self,
					true,
					Vector2(300, -100),
					1,
					0,
					1,
					Vector2(0, 0.1),
					2,
					Enums.Attack.NORMAL
	))
	tween.tween_interval(0.6)
	tween.tween_callback(enemy.hitted.bind(
					self,
					true,
					Vector2(400, -100),
					1,
					0,
					1,
					Vector2(0, 0.1),
					2,
					Enums.Attack.NORMAL
	))
	tween.tween_callback(enemy_2.hitted.bind(
					self,
					true,
					Vector2(400, -100),
					1,
					0,
					1,
					Vector2(0, 0.1),
					2,
					Enums.Attack.NORMAL
	))


func _ready() -> void:
	Settings.current_stage = "res://scenes/test3.tscn"

	CameraManager.enable_all_camera()
	CameraManager.set_zoom(Vector2.ONE)
	CameraManager.player = player

	test_wall_throw()
