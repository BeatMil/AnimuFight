extends Node2D


@onready var particles: Node2D = $Particles
var is_pooling_check := true


func _ready() -> void:
	if not is_pooling_check:
		$AnimationPlayer.play("crash")
		if get_tree().current_scene.get_node_or_null("Player/Camera"):
			get_tree().current_scene.get_node_or_null("Player/Camera"). \
			start_screen_shake(40, 0.3)
		else:
			print_debug("screenshake can't find player/camera")
	for p in particles.get_children():
		p.one_shot = true
		p.emitting = true
	await get_tree().create_timer(16).timeout
	queue_free()


func _on_gpu_particles_2d_finished() -> void:
	queue_free()
