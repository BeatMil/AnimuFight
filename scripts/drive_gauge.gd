extends Control


signal guage_up_sig
# signal hp_down_sig
# signal hp_out


@onready var progress_bar: ProgressBar = $DriveGuageWhitePart/ProgressBar
@onready var animation_player: AnimationPlayer = $AnimationPlayer


var tween: Tween
var immediate_value = 0


func set_max_value(_value: int) -> void:
	progress_bar.max_value = _value


func guage_up(_amount: int) -> void:
	immediate_value = min(immediate_value + _amount, progress_bar.max_value)

	if get_tree():
		# Make sure no tween left
		if tween:
			tween.kill()
		
		# Create new tween
		tween = create_tween()

		# smooth tween animation XD
		tween.tween_property(progress_bar, "value", immediate_value, 0.1)

	emit_signal("guage_up_sig")


func guage_down(_amount: int) -> bool:
	# Can't use move if not enough guage
	if immediate_value - _amount < 0:
		return false

	# Make sure immediate_value doesn't go below 0
	immediate_value = max(immediate_value - _amount, 0)

	# Make sure no tween left
	if get_tree():
		if tween:
			tween.kill()

		# Create new tween
		tween = create_tween()

		# smooth tween animation XD
		tween.tween_property(progress_bar, "value", immediate_value, 0.1)

		# animation_player.stop()
		# animation_player.play("guage_down")

	return true


func _ready() -> void:
	immediate_value = progress_bar.value
	await get_tree().create_timer(1).timeout
	# guage_up(6)
	# guage_down(5)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_2 and event.is_pressed():
		print("guage up!")
		guage_up(3)
	elif event is InputEventKey and event.keycode == KEY_3 and event.is_pressed():
		print("guage down!")
		guage_down(3)
