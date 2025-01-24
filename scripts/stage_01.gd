extends Node2D


var DEBRIS = preload("res://nodes/debris.tscn")

@onready var debris_animation_player: AnimationPlayer = $DebrisArea2D/AnimationPlayer
@onready var debris_area_2d: Area2D = $DebrisArea2D
@onready var no_door: Sprite2D = $DebrisArea2D/NoDoor
@onready var player: CharacterBody2D = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	# Set camera lock
	get_node_or_null("Player/Camera").set_screen_lock(0, 1920, -10000000, 1129)
	get_node_or_null("Player/Camera").set_zoom(Vector2(1,1))


func _on_debris_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if get_node_or_null("DebrisArea2D/NoDoor"):
			body._push_x_direct_old(-600)
			var debris = DEBRIS.instantiate()
			debris.position = $DebrisMarker2D.position
			add_child(debris)
			debris_animation_player.play("break_in")
			await get_tree().create_timer(0.1).timeout
			no_door.queue_free()
		else:
			body._push_x_direct_old(-600)
