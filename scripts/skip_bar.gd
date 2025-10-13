extends ProgressBar

@export var next_scene: String

var is_skipping: bool = false
# var is_fully_visible: bool = false
@onready var skip_bar_player: AnimationPlayer = $SkipBarPlayer
@onready var skip_bar: ProgressBar = $"."


func _physics_process(_delta: float) -> void:
	if is_skipping:
		skip_bar.value += skip_bar.step
	else:
		skip_bar.value -= skip_bar.step


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept") or event.is_action_pressed("pause"):
		is_skipping = true
		skip_bar_player.play("fade_in")
	elif event.is_action_released("ui_cancel") or event.is_action_released("ui_accept") or event.is_action_released("pause"):
		is_skipping = false
		skip_bar_player.play_backwards("fade_in")


# func _on_skip_bar_player_animation_finished(anim_name: StringName) -> void:
# 	if anim_name == "fade_in":
# 		print("fade_in: fishined!")
# 		is_fully_visible = true


func _on_value_changed(_value: float) -> void:
	if skip_bar.value == skip_bar.max_value:
		SceneTransition.change_scene(next_scene)
