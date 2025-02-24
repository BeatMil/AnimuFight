extends Node2D


@onready var player: CharacterBody2D = $Player
@onready var light_atk_label: Label = $CanvasLayer/LightAtkLabel
@onready var heavy_atk_label: Label = $CanvasLayer/HeavyAtkLabel
@onready var block_label: Label = $CanvasLayer/BlockLabel
@onready var dodge_label: Label = $CanvasLayer/DodgeLabel
@onready var training_menu: Control = $CanvasLayer/TrainingMenu
@onready var enemy_spawner_8: Node2D = $EnemySpawner8
@onready var enemy1: Object = preload("res://nodes/enemy_01.tscn")


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
