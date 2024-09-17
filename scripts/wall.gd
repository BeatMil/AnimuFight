extends StaticBody2D

@export var push_power = Vector2(400, -100)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_area_2dl_body_entered(body: Node2D) -> void:
	if body.is_in_group("character"):
		if "is_touching_wall_right" in body:
			body.is_touching_wall_right = true


func _on_area_2dr_body_entered(body: Node2D) -> void:
	if body.is_in_group("character"):
		if "is_touching_wall_left" in body:
			body.is_touching_wall_left = true


func _on_area_2dr_body_exited(body: Node2D) -> void:
	if body.is_in_group("character"):
		if "is_touching_wall_left" in body:
			body.is_touching_wall_left = false


func _on_area_2dl_body_exited(body: Node2D) -> void:
	if body.is_in_group("character"):
		if "is_touching_wall_right" in body:
			body.is_touching_wall_right = false
