extends Control


signal player_learn_tatsu


@onready var xbox_a: Sprite2D = $group/XboxA
@onready var xbox_b: Sprite2D = $group/XboxB
@onready var animation_player: AnimationPlayer = $NiceLabel/AnimationPlayer
@onready var nice_label: Label = $NiceLabel
@onready var nice_pos: Marker2D = $nicePos


func _input(_event: InputEvent) -> void:
	# Show input icon
	xbox_a.texture = InputDetector.get_icon_from_action("lp")
	xbox_b.texture = InputDetector.get_icon_from_action("hp")

	# Confirm player input tatsu
	if Input.is_action_just_pressed("lp") and Input.is_action_pressed("hp") \
		and Input.is_action_pressed("down") and visible:
		animation_player.play("nice")
		emit_signal("player_learn_tatsu")
		await get_tree().create_timer(0.8).timeout
		visible = false
		set_process_input(false)


func spawn_green_spark() -> void:
	ObjectPooling.spawn_green_spark(nice_pos.position)
