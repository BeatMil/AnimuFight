extends Node2D


#############################################################
## Node Ref
#############################################################
@onready var area_2d: Area2D = $Area2D
@onready var polygon_2d: Polygon2D = $Polygon2D


#############################################################
## Public
#############################################################
func turn_off():
	area_2d.monitoring = false
	polygon_2d.visible = false


func turn_on():
	area_2d.monitoring = true
	polygon_2d.visible = true


#############################################################
## Private
#############################################################
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("hitted"):
		print_rich("[color=orange][b]===DeathZone===[/b][/color]")
		body.hitted(
		self,
		true,
		Vector2.ZERO,
		0,
		0,
		0,
		Vector2(30, 0.5),
		9999,
		Enums.Attack.UNBLOCK,
		Vector2(0.8, 0.8),
		0
		)
