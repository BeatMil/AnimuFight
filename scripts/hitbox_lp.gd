extends Node2D

#############################################################
## Node Ref
#############################################################
@onready var timer: Timer = $Timer


#############################################################
## Built-in
#############################################################
func _ready() -> void:
	timer.start()


#############################################################
## Signals
#############################################################
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("hitted"):
		body.hitted(get_parent(), get_parent().is_face_right)



func _on_timer_timeout() -> void:
	queue_free()
