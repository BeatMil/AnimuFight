extends Node


@onready var attack_queue_timer: Timer = $AttackQueueTimer
@export var secs_between_attack: float = 1.5


var enemies_ready_to_attack = []
var enemies_priority_attack = []


func _ready() -> void:
	attack_queue_timer.wait_time = secs_between_attack


func queueing_to_attack(node: Object) -> void:
	enemies_ready_to_attack.append(node)


func queueing_priority(node: Object) -> void:
	enemies_priority_attack.append(node)

func start_queue_timer():
	attack_queue_timer.start()


func stop_queue_timer():
	attack_queue_timer.stop()


func queue_go() -> void:
	attack_queue_timer.start(0.1)
	attack_queue_timer.wait_time = secs_between_attack


func _on_attack_queue_timer_timeout() -> void:
	if enemies_priority_attack:
		var enemy = enemies_priority_attack.pick_random()
		if enemy:
			if enemy.has_method("do_attack"):
				enemy.do_attack()
				print("%s attacks! priority"%enemy.name)
	elif enemies_ready_to_attack:
		var enemy = enemies_ready_to_attack.pick_random()
		if enemy:
			if enemy.has_method("do_attack") and enemy.state == 0:
				enemy.do_attack()
				print("%s attacks!"%enemy.name)

	if enemies_priority_attack or enemies_ready_to_attack:
		enemies_ready_to_attack.clear()
		enemies_priority_attack.clear()
