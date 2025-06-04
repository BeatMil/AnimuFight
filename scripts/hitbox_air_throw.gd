extends "res://scripts/hitbox.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("get_is_bound"):
		if body.get_is_bound():
			push_power_ground *= 0.3
			push_power_air *= 0.3
		else:
			body.set_is_bound(true)
	super._on_area_2d_body_entered(body)
