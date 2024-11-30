extends Node2D

const ENEMY = preload("res://nodes/enemy.tscn")
@onready var enemy_count: Node = $enemyCount
@export var target: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_spawn_enemy()


func _spawn_enemy() -> void:
	var e = ENEMY.instantiate()
	e.position = self.position
	e.target = target
	enemy_count.add_child(e)
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if len(enemy_count.get_children()) <= 0:
		_spawn_enemy()
