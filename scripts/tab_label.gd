extends RichTextLabel


signal pressed


@export var tab_title: String
@export var tab_color: Color


@onready var tab_label: RichTextLabel = $"."
@onready var panel: Panel = $Panel
@onready var back_panel: Panel = $BackPanel


var stretch_ratio_selected = 2
var stretch_ratio_normal = 1
var fade_white = Color(0.5, 0.5, 0.5)
var normal_white = Color(1, 1, 1, 1)
var fade_tab_color: Color
var fade_tab_color_back_panel: Color


func _ready() -> void:
	tab_label.text = tab_title
	panel.get("theme_override_styles/panel").bg_color = tab_color
	fade_tab_color = tab_color.darkened(0.6)
	fade_tab_color_back_panel = tab_color.darkened(0.8)
	tab_label.set("theme_override_colors/default_color", Color(0.735, 0.735, 0.735))
	panel.get("theme_override_styles/panel").bg_color = fade_tab_color
	back_panel.get("theme_override_styles/panel").bg_color = fade_tab_color_back_panel


func fade_in() -> void:
	panel.get("theme_override_styles/panel").bg_color = tab_color
	back_panel.get("theme_override_styles/panel").bg_color = fade_tab_color
	var tween = create_tween()
	tween.tween_property(self, "size_flags_stretch_ratio",
	stretch_ratio_selected, 0.2)
	tween.parallel().tween_property(self,
	"theme_override_colors/default_color", normal_white, 0.1)


func fade_out() -> void:
	panel.get("theme_override_styles/panel").bg_color = fade_tab_color
	back_panel.get("theme_override_styles/panel").bg_color = fade_tab_color_back_panel
	var tween = create_tween()
	tween.tween_property(self, "size_flags_stretch_ratio",
	stretch_ratio_normal, 0.2)
	tween.parallel().tween_property(self,
	"theme_override_colors/default_color", fade_white, 0.1)


func _on_button_pressed() -> void:
	emit_signal("pressed")


func _on_mouse_entered() -> void:
	print("mouse enter")
	panel.get("theme_override_styles/panel").bg_color = tab_color
	back_panel.get("theme_override_styles/panel").bg_color = fade_tab_color
	var tween = create_tween()
	tween.parallel().tween_property(self,
	"theme_override_colors/default_color", normal_white, 0.1)


func _on_mouse_exited() -> void:
	print("mouse exit")
	if size_flags_stretch_ratio > stretch_ratio_normal:
		return
	panel.get("theme_override_styles/panel").bg_color = fade_tab_color
	back_panel.get("theme_override_styles/panel").bg_color = fade_tab_color_back_panel
	var tween = create_tween()
	tween.parallel().tween_property(self,
	"theme_override_colors/default_color", fade_white, 0.1)
