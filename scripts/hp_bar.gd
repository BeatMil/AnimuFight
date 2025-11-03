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
var immediate_value = 0


func _ready() -> void:
	immediate_value = value
	pass
	# tween = get_tree().create_tween()
# 	back_bar_tween = back_bar.create_tween()


#############################################################
## Public Functions
#############################################################
func hp_down(_amount: int) -> void:
	immediate_value = max(0, immediate_value - _amount)

	if get_parent().name == "PlayerCanvasLayer":
		pass
		# print("immHP: ", immediate_value," ", _amount)

	if immediate_value <= 0:
		cant_heal = true
		emit_signal("hp_out")

	if get_tree():
		back_bar.texture_progress = HP_BAR_RED
		if tween:
			tween.kill()

		tween = create_tween()
		tween.tween_property(self, "value", immediate_value, 0.1)
		tween.tween_property(back_bar, "value", immediate_value, 0.5)

	emit_signal("hp_down_sig")
	last_took_damage = _amount


func hp_up(_amount: int) -> void:
	if cant_heal:
		return
	
	immediate_value = min(immediate_value + _amount, max_value)
	
	if get_tree():
		back_bar.texture_progress = HP_BAR_GREEN
		if tween:
			tween.kill()
		
		# Create new tween
		tween = create_tween()
		
		# Make sure bars start from their current values
		back_bar.value = max(back_bar.value, value)
		
		# Animate the green bar quickly up to the healed value
		tween.tween_property(back_bar, "value", immediate_value, 0.1)
		
		# Then animate the main bar to catch up more slowly
		tween.tween_property(self, "value", immediate_value, 0.5)
	
	emit_signal("hp_up_sig")


func hp_up_late_parry() -> void:
	if get_tree():
		back_bar.texture_progress = HP_BAR_GREEN
		if tween:
			tween.kill()
		tween = create_tween()
		var heal_amount = max(last_took_damage/2, 1)
		immediate_value += heal_amount
		tween.tween_property(back_bar, "value", value + heal_amount, 0.1)
		tween.tween_property(self, "value", value + heal_amount, 0.5)
	emit_signal("hp_up_sig")


func resurrect(_amount: int) -> void:
	cant_heal = false
	max_value = _amount
	hp_up(_amount)


func get_hp() -> int:
	return immediate_value


func set_hp(_amount: int) -> void:
	max_value = _amount
	value = _amount
	back_bar.max_value = _amount
	back_bar.value = _amount
	immediate_value = _amount
