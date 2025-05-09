extends Node2D

@onready var enemy_count: Node = $enemyCount
@export var target: CharacterBody2D
@export var enemy_to_spawn: Array[Node]
@export var is_active: bool = true
var phase: int = 0


func _ready() -> void:
	pass


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
		enemy_count.add_child(e)
		enemy_to_spawn.erase(enemy)
		await get_tree().create_timer(0.1).timeout
	
	
func _process(_delta: float) -> void:
	if len(enemy_count.get_children()) <= 0 and is_active:
		if phase == 5:
			get_parent().emit_signal("shoot_up_house")
		phase += 1
		_spawn_enemy()
