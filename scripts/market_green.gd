extends "res://scripts/bed.gd"

@onready var area_2d: Area2D = $Area2D
const STAND = preload("res://media/sprites/stage01/stand.png")
@onready var mangos: Node2D = $Mangos
@onready var mango_on_stand: Sprite2D = $MangoOnStand
@onready var banana_audio_player: AudioStreamPlayer = $BananaAudioPlayer
var is_activated = false

signal banana_fly

func _ready() -> void:
	for m in mangos.get_children():
		m.collision_mask = 0b00000000000001000000


func set_active(value: bool) -> void:
	area_2d.monitoring = value
	print(area_2d.monitoring)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if not area.visible:
		return
	super._on_area_2d_area_entered(area)
	mangos.set_deferred("visible", true)
	if not is_activated:
		for m in mangos.get_children():
			# m.set_deferred("freeze", false)
			# await get_tree().create_timer(0.1).timeout
			m.collision_mask = 0b00000000000001111111
			m.gravity_scale = 1.5
			var power = 1000
			m.apply_impulse(
				Vector2(randi_range(-power, power), -power
				))
		emit_signal("banana_fly")
		is_activated = true
		mango_on_stand.texture = STAND
		banana_audio_player.play()
