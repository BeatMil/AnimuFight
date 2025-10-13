extends Node2D

@onready var enemy_count: Node = $enemyCount
@export var target: CharacterBody2D
@export var enemy_to_spawn: Array[Node]
@export var is_active: bool = true
var phase: int = 0

signal area_done


func _ready() -> void:
	phase = Settings.checkpoint


func _spawn_enemy() -> void:
	# Parry array out of index error
	if phase-1 >= len(enemy_to_spawn):
		return
	var enemy_to_spawn_copy = enemy_to_spawn[phase-1].get_children().duplicate()

	for enemy in enemy_to_spawn_copy:
		var e = enemy.object.instantiate()
		e.position = enemy.position.position
		e.target = target
		e.hp = enemy.hp
		e.block_rate = enemy.block_rate
		enemy_count.add_child(e)
		enemy_to_spawn.erase(enemy)
		await get_tree().create_timer(0.1).timeout
	
	
func _process(_delta: float) -> void:
	if len(enemy_count.get_children()) <= 0 and is_active:
		if phase == len(enemy_to_spawn):
			is_active = false
			print("stop spawning!")
			emit_signal("area_done")
			return
		phase += 1
		_spawn_enemy()
