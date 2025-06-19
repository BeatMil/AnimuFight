extends TextureProgressBar
@onready var back_bar: TextureProgressBar = $BackBar


#############################################################
## Signals
#############################################################
signal hp_up_sig
signal hp_down_sig

#############################################################
## Public Functions
#############################################################
func hp_down(_amount: int) -> void:
	# value -= _amount
	var tween = get_tree().create_tween()
	tween.tween_property(self, "value", value - _amount, 0.1)
	tween.tween_property(back_bar, "value", value - _amount, 0.5)
	emit_signal("hp_down_sig")


func hp_up(_amount: int) -> void:
	# value += _amount
	var tween = get_tree().create_tween()
	tween.tween_property(self, "value", value + _amount, 0.1)
	tween.tween_property(back_bar, "value", value + _amount, 0.5)
	emit_signal("hp_up_sig")


func get_hp() -> int:
	return int(value)


func set_hp(_amount: int) -> void:
	max_value = _amount
	value = max_value
	back_bar.max_value = _amount
	back_bar.value = max_value
