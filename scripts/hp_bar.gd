extends TextureProgressBar
@onready var back_bar: TextureProgressBar = $BackBar


#############################################################
## Signals
#############################################################
signal hp_up_sig
signal hp_down_sig
signal hp_out

var cant_heal = false
var last_took_damage := 0

#############################################################
## Public Functions
#############################################################
func hp_down(_amount: int) -> void:
	# value -= _amount
	if get_tree():
		var tween = get_tree().create_tween()
		tween.tween_property(self, "value", value - _amount, 0.1)
		tween.tween_property(back_bar, "value", value - _amount, 0.5)
	emit_signal("hp_down_sig")
	await get_tree().create_timer(0.2).timeout
	if value <= 0:
		emit_signal("hp_out")
		cant_heal = true
	last_took_damage = _amount
	pass


func hp_up(_amount: int) -> void:
	if cant_heal:
		return
	# value += _amount
	if get_tree():
		var tween = get_tree().create_tween()
		tween.tween_property(self, "value", value + _amount, 0.1)
		tween.tween_property(back_bar, "value", value + _amount, 0.5)
	emit_signal("hp_up_sig")


func hp_up_late_parry() -> void:
	print("value_before:", value)
	if get_tree():
		var tween = get_tree().create_tween()
		var heal_amount = max(last_took_damage/2, 1)
		tween.tween_property(self, "value", value + heal_amount, 0.1)
		tween.tween_property(back_bar, "value", value + heal_amount, 0.5)
		print("last_took_damage:", last_took_damage)
		print("last_took_damage/2:", last_took_damage/2)
	await get_tree().create_timer(0.2).timeout
	print("value_after:", value)
	emit_signal("hp_up_sig")



func get_hp() -> int:
	return int(value)


func set_hp(_amount: int) -> void:
	max_value = _amount
	value = max_value
	back_bar.max_value = _amount
	back_bar.value = max_value
