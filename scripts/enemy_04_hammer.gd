extends Node2D

@onready var sprite_2d: Sprite2D = $"../Sprite2D"

func _physics_process(_delta: float) -> void:
	## Flip hammer attack (rotation)
	if sprite_2d.flip_h:
		scale.x = -1
	else:
		scale.x = 1
