extends "res://scripts/hit_spark.gd"

func _ready() -> void:
	for i in groups.get_children():
		i.emitting = true
		
	
	await get_tree().create_timer(20).timeout
	queue_free()
