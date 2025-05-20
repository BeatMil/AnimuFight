extends Node2D


var SSR_LABEL = preload("res://nodes/ssr_label.tscn")
var NEXT = preload("res://scenes/intro_2.tscn")


func _spawn_label_1(_label: String) -> void:
	var label = SSR_LABEL.instantiate()
	label.label = _label
	label.position = $SsrLabelMarker2D.position
	add_child(label)


func _spawn_label_2(_label: String) -> void:
	var label = SSR_LABEL.instantiate()
	label.label = _label
	label.position = $ALabelMarker2D.position
	add_child(label)

func _spawn_label_3(_label: String) -> void:
	var label = SSR_LABEL.instantiate()
	label.label = _label
	label.position = $ALabelMarker2D2.position
	add_child(label)

func _spawn_label_4(_label: String) -> void:
	var label = SSR_LABEL.instantiate()
	label.label = _label
	label.position = $BLabelMarker2D.position
	add_child(label)

func _spawn_label_5(_label: String) -> void:
	var label = SSR_LABEL.instantiate()
	label.label = _label
	label.position = $BLabelMarker2D2.position
	add_child(label)

func _spawn_label_6(_label: String) -> void:
	var label = SSR_LABEL.instantiate()
	label.label = _label
	label.position = $BLabelMarker2D3.position
	add_child(label)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"a":
			$AnimationPlayer.play("b")
		"b":
			$AnimationPlayer.play("c")
		"c":
			get_tree().change_scene_to_file("res://scenes/intro_2.tscn")
