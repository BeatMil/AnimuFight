extends Node2D


@onready var player: CharacterBody2D = $Player
@onready var light_atk_label: Label = $CanvasLayer/LightAtkLabel
@onready var heavy_atk_label: Label = $CanvasLayer/HeavyAtkLabel
@onready var block_label: Label = $CanvasLayer/BlockLabel
@onready var dodge_label: Label = $CanvasLayer/DodgeLabel
@onready var training_menu: Control = $CanvasLayer/TrainingMenu
@onready var enemy_spawner_8: Node2D = $EnemySpawner8
@onready var mango_boss: Object = preload("res://nodes/mango_boss.tscn")
@onready var boss01: Object = preload("res://nodes/boss01.tscn")
@onready var enemy2: Object = preload("res://nodes/enemy_02.tscn")
@onready var enemy3: Object = preload("res://nodes/enemy_03.tscn")
const enemy4 = preload("uid://bhw2h1n6yqhk8")
const enemy1 = preload("uid://b2vaqeiw3q18o")
const enemy6 = preload("uid://d0ufo617puti8")

@onready var death_zone: Node2D = $DeathZone
@onready var wall_player: AnimationPlayer = $WallPlayer

const ENEMY_ZONER_01 = preload("uid://chyv0gcd42b0i")


func _ready() -> void:
	CameraManager.enable_all_camera()
	CameraManager.disable_screen_lock()
	CameraManager.player = player
	CameraManager.is_following_player = true
	CameraManager.make_current(0)

	training_menu.visible = false
	training_menu.boss01.connect(_on_boss01_button_down)
	training_menu.mangoBoss.connect(_on_mango_boss_button_down)
	training_menu.enemy1.connect(_on_enemy_1_button_down)
	training_menu.enemy2.connect(_on_enemy_2_button_down)
	training_menu.enemy3.connect(_on_enemy_3_button_down)
	training_menu.enemy4.connect(_on_enemy_4_button_down)
	training_menu.enemy6.connect(_on_enemy_6_button_down)
	training_menu.enemy_zoner_1.connect(_on_enemy_zoner_1_button_down)
	training_menu.clear.connect(_on_clear_button_down)
	training_menu.death_zone.connect(_on_death_zone_toggled)
	training_menu.wall.connect(_on_wall_toggled)
	death_zone.turn_off()
	AttackQueue.stop_queue_timer()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("lp"):
		light_atk_label.turn_green()
	if event.is_action_pressed("hp"):
		heavy_atk_label.turn_green()
	if event.is_action_pressed("block"):
		block_label.turn_green()
	if event.is_action_pressed("dodge"):
		dodge_label.turn_green()
	

func clear_enemy() -> void:
	enemy_spawner_8.enemy_to_spawn.clear()
	enemy_spawner_8.clear_enemy()


func _on_clear_button_down() -> void:
	clear_enemy()


func _on_boss01_button_down() -> void:
	clear_enemy()
	enemy_spawner_8.enemy_to_spawn.append(boss01)


func _on_mango_boss_button_down() -> void:
	clear_enemy()
	enemy_spawner_8.enemy_to_spawn.append(mango_boss)


func _on_enemy_1_button_down() -> void:
	clear_enemy()
	enemy_spawner_8.enemy_to_spawn.append(enemy1)


func _on_enemy_2_button_down() -> void:
	clear_enemy()
	enemy_spawner_8.enemy_to_spawn.append(enemy2)


func _on_enemy_3_button_down() -> void:
	clear_enemy()
	enemy_spawner_8.enemy_to_spawn.append(enemy3)


func _on_enemy_4_button_down() -> void:
	clear_enemy()
	enemy_spawner_8.enemy_to_spawn.append(enemy4)


func _on_enemy_6_button_down() -> void:
	clear_enemy()
	enemy_spawner_8.enemy_to_spawn.append(enemy6)


func _on_enemy_zoner_1_button_down() -> void:
	clear_enemy()
	enemy_spawner_8.enemy_to_spawn.append(ENEMY_ZONER_01)


func _on_death_zone_toggled(toggled_on: bool) -> void:
	if toggled_on:
		death_zone.turn_on()
	else:
		death_zone.turn_off()


func _on_wall_toggled(toggled_on: bool) -> void:
	if toggled_on:
		wall_player.play("wall")
	else:
		wall_player.play("no_wall")
