extends "res://scripts/hitbox.gd"

@export var is_push_right: bool


func facing_helper() -> bool:
	return is_push_right
