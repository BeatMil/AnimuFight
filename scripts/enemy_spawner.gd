extends Node2D

@onready var enemy_count: Node = $enemyCount
@export var target: CharacterBody2D
@export var enemy_to_spawn: Array
@export var is_active: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _spawn_enemy() -> void:
	if not enemy_to_spawn:
		return
	var bob = enemy_to_spawn.pick_random()
	var e = bob.instantiate()
	e.position = self.position
	if not target:
		e.is_notarget = true
	else:
		e.target = target
	enemy_count.add_child(e)


func clear_enemy() -> void:
	for node in enemy_count.get_children():
		node.queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if len(enemy_count.get_children()) <= 0 and is_active:
		_spawn_enemy()
