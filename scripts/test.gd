extends Node2D


const PLAYER = preload("res://scenes/test2.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	print(get_tree().current_scene.name)
	var new_scene = PLAYER.instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
