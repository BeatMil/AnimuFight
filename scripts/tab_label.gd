extends RichTextLabel

@export var tab_title: String
@export var tab_color: Color


@onready var tab_label: RichTextLabel = $"."
@onready var panel: Panel = $Panel
@onready var back_panel: Panel = $BackPanel


var stretch_ratio_selected = 2
var stretch_ratio_normal = 1
var fade_white = Color(0.735, 0.735, 0.735)
var normal_white = Color(1, 1, 1, 1)
var fade_tab_color: Color


func _ready() -> void:
	tab_label.text = tab_title
	panel.get("theme_override_styles/panel").bg_color = tab_color
	fade_tab_color = tab_color.darkened(0.6)
	tab_label.set("theme_override_colors/default_color", Color(0.735, 0.735, 0.735))
	panel.get("theme_override_styles/panel").bg_color = fade_tab_color
	back_panel.get("theme_override_styles/panel").bg_color = fade_tab_color

func fade_in() -> void:
	panel.get("theme_override_styles/panel").bg_color = tab_color
	var tween = get_tree().create_tween()
	tween.tween_property(self, "size_flags_stretch_ratio",
	stretch_ratio_selected, 0.2)
	tween.parallel().tween_property(self,
	"theme_override_colors/default_color", normal_white, 0.1)


func fade_out() -> void:
	panel.get("theme_override_styles/panel").bg_color = fade_tab_color
	var tween = get_tree().create_tween()
	tween.tween_property(self, "size_flags_stretch_ratio",
	stretch_ratio_normal, 0.2)
	tween.parallel().tween_property(self,
	"theme_override_colors/default_color", fade_white, 0.1)
