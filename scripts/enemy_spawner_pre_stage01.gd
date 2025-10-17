extends Node2D

@onready var enemy_count: Node = $enemyCount
@export var target: CharacterBody2D
@export var enemy_to_spawn: Array[Node]
@export var is_active: bool = true
var is_shoot_up_house: bool = false
var phase: int = 0


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
		if e.name == "Boss01":
			e.boss_defeated.connect(get_parent().boss_defeated)
			get_parent().boss = e
		enemy_count.add_child(e)
		enemy_to_spawn.erase(enemy)
		await get_tree().create_timer(0.1).timeout
	
	
func _process(_delta: float) -> void:
	if len(enemy_count.get_children()) <= 0 and is_active:
		if phase == 8:
			Settings.checkpoint = 8
		elif phase == 5:
			Settings.checkpoint = 5

		if phase >= 5:
			if not is_shoot_up_house:
				is_shoot_up_house = true
				get_parent()._shoot_up_house()
		phase += 1
		_spawn_enemy()
