extends Node2D


@onready var player: CharacterBody2D = $Player
@onready var light_atk_label: Label = $CanvasLayer/LightAtkLabel
@onready var heavy_atk_label: Label = $CanvasLayer/HeavyAtkLabel
@onready var block_label: Label = $CanvasLayer/BlockLabel
@onready var dodge_label: Label = $CanvasLayer/DodgeLabel
@onready var training_menu: Control = $CanvasLayer/TrainingMenu
@onready var enemy_spawner_8: Node2D = $EnemySpawner8
@onready var enemy1: Object = preload("res://nodes/enemy_01.tscn")
@onready var enemy2: Object = preload("res://nodes/enemy_02.tscn")
@onready var enemy3: Object = preload("res://nodes/enemy_03.tscn")
@onready var enemy4: Object = preload("res://nodes/enemy_04.tscn")
@onready var death_zone: Node2D = $DeathZone

func _ready() -> void:
	training_menu.visible = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("lp"):
		light_atk_label.turn_green()
	if event.is_action_pressed("hp"):
		heavy_atk_label.turn_green()
	if event.is_action_pressed("block"):
		block_label.turn_green()
	if event.is_action_pressed("dodge"):
		dodge_label.turn_green()
	
	if event.is_action_pressed("pause"):
		training_menu.visible = !training_menu.visible


func _on_clear_button_down() -> void:
	enemy_spawner_8.enemy_to_spawn.clear()
	enemy_spawner_8.clear_enemy()


func _on_enemy_1_button_down() -> void:
	enemy_spawner_8.enemy_to_spawn.append(enemy1)


func _on_enemy_2_button_down() -> void:
	enemy_spawner_8.enemy_to_spawn.append(enemy2)


func _on_enemy_3_button_down() -> void:
	enemy_spawner_8.enemy_to_spawn.append(enemy3)


func _on_enemy_4_button_down() -> void:
	enemy_spawner_8.enemy_to_spawn.append(enemy4)


func _on_death_zone_toggled(toggled_on: bool) -> void:
	if toggled_on:
		death_zone.turn_on()
	else:
		death_zone.turn_off()
