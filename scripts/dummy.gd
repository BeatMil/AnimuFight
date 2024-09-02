extends CharacterBody2D


#############################################################
## Node Ref
#############################################################
@onready var animation_player: AnimationPlayer = $AnimationPlayer


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
