extends "res://scripts/hit_spark.gd"

var is_stay = false

func _ready() -> void:
	for i in groups.get_children():
		i.emitting = true
		
	
	if is_stay:
		await get_tree().create_timer(0.75).timeout
		for i in groups.get_children():
			i.emitting = false
		await get_tree().create_timer(1).timeout
		queue_free()
	else:
		await get_tree().create_timer(20).timeout
		queue_free()
