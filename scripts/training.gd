extends Node2D


@onready var player: CharacterBody2D = $Player
@onready var light_atk_label: Label = $CanvasLayer/LightAtkLabel
@onready var heavy_atk_label: Label = $CanvasLayer/HeavyAtkLabel
@onready var block_label: Label = $CanvasLayer/BlockLabel


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("lp"):
		light_atk_label.turn_green()
	if event.is_action_pressed("hp"):
		heavy_atk_label.turn_green()
	if event.is_action_pressed("block"):
		block_label.turn_green()
