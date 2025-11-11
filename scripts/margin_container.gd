extends MarginContainer


# This code sample assumes the current script is extending MarginContainer.
var margin_value = 160


func _ready() -> void:
	add_theme_constant_override("margin_top", margin_value)
	add_theme_constant_override("margin_left", margin_value)
	add_theme_constant_override("margin_bottom", margin_value)
	add_theme_constant_override("margin_right", margin_value)
