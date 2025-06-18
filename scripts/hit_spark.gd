extends Node2D
@onready var groups: Node2D = $groups


func _ready() -> void:
	for i in groups.get_children():
		i.one_shot = true
		i.emitting = true
		
	
	await get_tree().create_timer(5).timeout
	queue_free()


func _on_gpu_particles_2d_finished() -> void:
	queue_free()
