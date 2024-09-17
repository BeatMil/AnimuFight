extends StaticBody2D

@export var push_power = Vector2(400, -100)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_area_2dl_body_entered(body: Node2D) -> void:
	if body.is_in_group("character"):
		if body.state == 5: ## HIT_STUNNED
			body.hitted(null, false, push_power, Enums.Push_types.NORMAL)


func _on_area_2dr_body_entered(body: Node2D) -> void:
	print_rich("[color=pink][b]body: %sNyaaa > w <[/b][/color]"%body)
	if body.is_in_group("character"):
		if body.state == 5: ## HIT_STUNNED
			body.hitted(null, true, push_power, Enums.Push_types.NORMAL)
