extends "res://scripts/hitbox.gd"


var target_pos: Vector2
var self_pos: Vector2
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D


func _ready() -> void:
	pass
	var seg_shape = SegmentShape2D.new()
	seg_shape.a = Vector2.ZERO
	seg_shape.b = target_pos - self_pos
	collision_shape_2d.shape = seg_shape
