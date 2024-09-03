extends CharacterBody2D


#############################################################
## Node Ref
#############################################################
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var lp_pos: Marker2D = $HitBoxPos/LpPos
@onready var sprite_2d: Sprite2D = $Sprite2D


#############################################################
## Preloads
#############################################################
const HITBOX_LP = preload("res://nodes/hitboxes/hitbox_lp.tscn")


#############################################################
## Built-in
#############################################################
func _physics_process(_delta: float) -> void:
	_z_index_equal_to_y()


#############################################################
## Private functions
#############################################################
func _z_index_equal_to_y() -> void:
	z_index = int(position.y)


"""
animation_player uses
"""
func _spawn_lp_hitbox() -> void:
	var hitbox = HITBOX_LP.instantiate()
	if sprite_2d.flip_h: ## facing left
		hitbox.position = Vector2(-lp_pos.position.x, lp_pos.position.y)
	else: ## facing left
		hitbox.position = Vector2(lp_pos.position.x, lp_pos.position.y)
	add_child(hitbox)
#############################################################
## Public functions
#############################################################
func hitted() -> void:
	animation_player.stop(true)
	animation_player.play("hitted")


#############################################################
## Signals
#############################################################
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hitted":
		animation_player.play("idle")
