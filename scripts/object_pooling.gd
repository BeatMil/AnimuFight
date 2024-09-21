extends Node


#############################################################
## Preloads
#############################################################
const HITSPARK = preload("res://nodes/hitsparks/hit_spark.tscn")


#############################################################
## Config
#############################################################
var pooling_pos = Vector2(-100000, -10000)


func _ready() -> void:
	spawn_hitSpark_1()


func spawn_hitSpark_1(_position: Vector2 = pooling_pos) -> void:
	var hitspark = HITSPARK.instantiate()
	hitspark.position = _position
	get_tree().current_scene.add_child(hitspark)
