extends Node2D


var SSR_LABEL = preload("res://nodes/ssr_label.tscn")
var NEXT = preload("res://scenes/intro_2.tscn")
@onready var skip_bar: ProgressBar = $CanvasLayer/SkipBar
var is_skipping: bool = false
var is_fully_visible: bool = false
@onready var skip_bar_player: AnimationPlayer = $CanvasLayer/SkipBar/SkipBarPlayer


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


func _physics_process(delta: float) -> void:
	if is_skipping:
		skip_bar.value += skip_bar.step
	else:
		skip_bar.value -= skip_bar.step


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		is_skipping = true
		skip_bar_player.play("fade_in")
	elif Input.is_action_just_released("ui_cancel"):
		is_skipping = false
		skip_bar_player.play_backwards("fade_in")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"a":
			$AnimationPlayer.play("b")
		"b":
			$AnimationPlayer.play("c")
		"c":
			get_tree().change_scene_to_file("res://scenes/intro_2.tscn")


func _on_skip_bar_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in":
		print("fade_in: fishined!")
		is_fully_visible = true


func _on_skip_bar_value_changed(value: float) -> void:
	if skip_bar.value == skip_bar.max_value:
		SceneTransition.change_scene("res://scenes/stage01.tscn")
