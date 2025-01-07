extends Node2D


var DEBRIS = preload("res://nodes/debris.tscn")

@onready var debris_animation_player: AnimationPlayer = $DebrisArea2D/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _on_debris_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		var debris = DEBRIS.instantiate()
		debris.position = $DebrisMarker2D.position
		add_child(debris)
		print("Spawn debris!")
		
		debris_animation_player.play("break_in")
		body._push_x_direct_old(-300)
