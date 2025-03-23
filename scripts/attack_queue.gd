extends Node

@onready var attack_queue_timer: Timer = $AttackQueueTimer


var can_attack: bool = false


func start_queue_timer():
	can_attack = false
	attack_queue_timer.start()
	print_rich("[color=yellow][b]run: wait 1 sec[/b][/color]")


func _on_attack_queue_timer_timeout() -> void:
	can_attack = true
	attack_queue_timer.stop()
	print_rich("[color=green][b]run: can_attack![/b][/color]", can_attack)
