extends TextureProgressBar
@onready var back_bar: TextureProgressBar = $BackBar
const HP_BAR_GREEN = preload("res://media/sprites/hp_bar/hp_bar_green.png")
const HP_BAR_RED = preload("res://media/sprites/hp_bar/hp_bar_red.png")

#############################################################
## Signals
#############################################################
signal hp_up_sig
signal hp_down_sig
signal hp_out

var cant_heal = false
var last_took_damage := 0
var tween


func _ready() -> void:
	pass
	# tween = get_tree().create_tween()
# 	back_bar_tween = back_bar.create_tween()


#############################################################
## Public Functions
#############################################################
func hp_down(_amount: int) -> void:
	# value -= _amount
	if get_tree():
		back_bar.texture_progress = HP_BAR_RED
		if tween:
			tween.kill()
		tween = create_tween()
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
		back_bar.texture_progress = HP_BAR_GREEN
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property(back_bar, "value", value + _amount, 0.1)
		tween.tween_property(self, "value", value + _amount, 0.5)
	emit_signal("hp_up_sig")


func hp_up_late_parry() -> void:
	if get_tree():
		back_bar.texture_progress = HP_BAR_GREEN
		if tween:
			tween.kill()
		tween = create_tween()
		var heal_amount = max(last_took_damage/2, 1)
		tween.tween_property(back_bar, "value", value + heal_amount, 0.1)
		tween.tween_property(self, "value", value + heal_amount, 0.5)
	emit_signal("hp_up_sig")



func get_hp() -> int:
	return int(value)


func set_hp(_amount: int) -> void:
	max_value = _amount
	value = max_value
	back_bar.max_value = _amount
	back_bar.value = max_value
