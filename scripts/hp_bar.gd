extends ProgressBar


#############################################################
## Public Functions
#############################################################
func hp_down(_amount: int) -> void:
	value -= _amount


func hp_up(_amount: int) -> void:
	value += _amount


func get_hp() -> int:
	return int(value)


func set_hp(_amount: int) -> void:
	value = _amount
