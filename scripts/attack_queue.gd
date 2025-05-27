extends Node


@onready var attack_queue_timer: Timer = $AttackQueueTimer


var enemies_ready_to_attack = []


func queueing_to_attack(node: Object) -> void:
	enemies_ready_to_attack.append(node)


func start_queue_timer():
	attack_queue_timer.start()
	# print_rich("[color=yellow][b]I Attack![/b][/color]")


func stop_queue_timer():
	attack_queue_timer.stop()


func _on_attack_queue_timer_timeout() -> void:
	if enemies_ready_to_attack:
		var enemy = enemies_ready_to_attack.pick_random()
		if enemy.has_method("do_attack"):
			enemy.do_attack()
			print("%s attacks!"%enemy)
		print(enemies_ready_to_attack)
		enemies_ready_to_attack.clear()
