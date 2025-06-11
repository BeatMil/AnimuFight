extends "res://scripts/hitbox.gd"


func _ready() -> void:
	super._ready()
	area_2d.collision_mask = 0b00000000000010000000
