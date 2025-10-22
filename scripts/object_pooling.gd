extends Node


#############################################################
## Preloads
#############################################################
const HITSPARK = preload("res://nodes/hitsparks/hit_spark.tscn")
const BLOCKSPARK = preload("res://nodes/hitsparks/block_spark.tscn")
const BLOCKSPARK2 = preload("res://nodes/hitsparks/block_spark2.tscn")
const GROUNDSPARK = preload("res://nodes/hitsparks/ground_particle.tscn")
const SANDSPARK_R = preload("res://nodes/hitsparks/sand_particleR.tscn")
const SANDSPARK_L = preload("res://nodes/hitsparks/sand_particleL.tscn")
const ATTACK_TYPE_INDICATOR = preload("res://nodes/attack_type_indicator.tscn")
const GLASS_SPARK = preload("res://nodes/hitsparks/glass_spark_cool.tscn")
const JUCTION_SPARK = preload("res://nodes/hitsparks/juction_particle.tscn")
const THROW_SPARK_GROUND = preload("res://nodes/hitsparks/throw_spark_ground.tscn")
const THROW_SPARK_FLOAT = preload("res://nodes/hitsparks/throw_spark_float.tscn")
const IFRAMESPARK = preload("res://nodes/hitsparks/iframe_spark.tscn")
const HIT_SPARK_COOL = preload("res://nodes/hitsparks/hit_spark_cool.tscn")
const GROUND_PARTICLE_2 = preload("uid://bb5sw8ogwptbc")
const EWGF_SPARK = preload("uid://cj5pmswumq8oa")
const HELI_BOMB_WARNING = preload("uid://cffmpmpmvl5pw")
const BOOM_SPARK = preload("uid://nf1iaj3ndswq")
const GREEN_SPARK = preload("uid://dj75v1eu27yjx")


#############################################################
## Config
#############################################################
var pooling_pos = Vector2(-100000, -10000)


func _ready() -> void:
	spawn_hitSpark_1()
	spawn_blockSpark_1()
	spawn_attack_type_indicator()
	spawn_ground_spark(pooling_pos, true)


func spawn_hitSpark_1(_position: Vector2 = pooling_pos) -> void:
	var hitspark = HITSPARK.instantiate()
	hitspark.position = _position
	get_tree().current_scene.add_child(hitspark)


func spawn_blockSpark_1(_position: Vector2 = pooling_pos) -> void:
	var hitspark = BLOCKSPARK.instantiate()
	hitspark.position = _position
	get_tree().current_scene.add_child(hitspark)


func spawn_blockSpark_2(_position: Vector2 = pooling_pos) -> void:
	var hitspark = BLOCKSPARK2.instantiate()
	hitspark.position = _position
	get_tree().current_scene.add_child(hitspark)


func spawn_ground_spark(_position: Vector2 = pooling_pos, is_pooling_check: bool = false) -> void:
	var hitspark = GROUNDSPARK.instantiate()
	hitspark.position = _position
	hitspark.is_pooling_check = is_pooling_check
	get_tree().current_scene.add_child(hitspark)


func spawn_attack_type_indicator(_type: int = 0, pos: Vector2 = pooling_pos) -> void:
	var bob = ATTACK_TYPE_INDICATOR.instantiate()
	bob.type = _type
	bob.position = pos
	get_tree().current_scene.add_child(bob)


func spawn_sand_sparkR(_position: Vector2 = pooling_pos) -> void:
	var hitspark = SANDSPARK_R.instantiate()
	hitspark.position = _position
	get_tree().current_scene.add_child(hitspark)


func spawn_sand_sparkL(_position: Vector2 = pooling_pos) -> void:
	var hitspark = SANDSPARK_L.instantiate()
	hitspark.position = _position
	get_tree().current_scene.add_child(hitspark)


func spawn_glass_spark(_position: Vector2 = pooling_pos) -> void:
	var hitspark = GLASS_SPARK.instantiate()
	hitspark.position = _position
	get_tree().current_scene.add_child(hitspark)


func spawn_juction_glass(_position: Vector2 = pooling_pos) -> void:
	var hitspark = JUCTION_SPARK.instantiate()
	hitspark.position = _position
	get_tree().current_scene.add_child(hitspark)


func spawn_throw_spark_ground(_position: Vector2 = pooling_pos) -> void:
	var hitspark = THROW_SPARK_GROUND.instantiate()
	hitspark.position = _position
	get_tree().current_scene.add_child(hitspark)


func spawn_throw_spark_float(_position: Vector2 = pooling_pos) -> void:
	var hitspark = THROW_SPARK_FLOAT.instantiate()
	hitspark.position = _position
	get_tree().current_scene.add_child(hitspark)


func spawn_iframe_spark(_position: Vector2 = pooling_pos) -> void:
	var hitspark = IFRAMESPARK.instantiate()
	hitspark.position = _position
	get_tree().current_scene.add_child(hitspark)


func spawn_hit_spark_cool(_position: Vector2 = pooling_pos) -> void:
	var hitspark = HIT_SPARK_COOL.instantiate()
	hitspark.position = _position
	get_tree().current_scene.add_child(hitspark)


func spawn_ground_spark_2(_position: Vector2 = pooling_pos) -> void:
	var hitspark = GROUND_PARTICLE_2.instantiate()
	hitspark.position = _position
	get_tree().current_scene.add_child(hitspark)


func spawn_EWGF_spark(_position: Vector2 = pooling_pos, _flip_h = false) -> void:
	var hitspark = EWGF_SPARK.instantiate()
	var pos_pos: Vector2
	if _flip_h:
		pos_pos = _position + Vector2(-100, 0)
	else:
		pos_pos = _position + Vector2(100, 0)
	hitspark.position = pos_pos
	hitspark.z_index = 20
	get_tree().current_scene.add_child(hitspark)
	var tween = get_tree().create_tween()
	var new_pos: Vector2
	if _flip_h:
		new_pos = hitspark.position + Vector2(-100, -200)
	else:
		new_pos = hitspark.position + Vector2(100, -200)

	tween.tween_property(hitspark, "position", new_pos, 0.2).set_trans(Tween.TRANS_CUBIC)


func spawn_fire_hydrant_spark(_position: Vector2 = pooling_pos) -> void:
	var hitspark = EWGF_SPARK.instantiate()
	hitspark.position = _position
	hitspark.z_index = 20
	get_tree().current_scene.add_child(hitspark)
	var tween = get_tree().create_tween()
	var new_pos = hitspark.position + Vector2(0, -300)
	tween.tween_property(hitspark, "position", new_pos, 0.2).set_trans(Tween.TRANS_CUBIC)


func spawn_heli_bomb_warning(_position: Vector2 = pooling_pos, pitch_scale = 1.0) -> void:
	var hitspark = HELI_BOMB_WARNING.instantiate()
	hitspark.position = _position
	hitspark.pitch_scale = pitch_scale
	get_tree().current_scene.add_child(hitspark)


func spawn_boom_spark(_position: Vector2 = pooling_pos, is_stay = false) -> void:
	var hitspark = BOOM_SPARK.instantiate()
	hitspark.position = _position
	hitspark.is_stay = is_stay
	get_tree().current_scene.add_child(hitspark)


func spawn_green_spark(_position: Vector2 = pooling_pos) -> void:
	var hitspark = GREEN_SPARK.instantiate()
	hitspark.position = _position
	get_tree().current_scene.add_child(hitspark)
