extends Node2D


func _ready() -> void:
	$GPUParticles2D.one_shot = true
	$GPUParticles2D.emitting = true
	await get_tree().create_timer(5).timeout
	queue_free()


func _on_gpu_particles_2d_finished() -> void:
	queue_free()
