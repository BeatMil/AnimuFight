extends Node2D


var DEBRIS = preload("res://nodes/debris.tscn")
var DEBRIS_UP = preload("res://nodes/debris_upward.tscn")
const BOSS_BOUNCE_SFX = preload("res://media/sfxs/unequip01.wav")

@onready var debris_animation_player: AnimationPlayer = $DebrisArea2D/AnimationPlayer
@onready var debris_area_2d: Area2D = $DebrisArea2D
@onready var no_door: Sprite2D = $DebrisArea2D/NoDoor
@onready var player: CharacterBody2D = $Player
@onready var music_player: AnimationPlayer = $MusicPlayer
@onready var animation_player: AnimationPlayer = $Background/AnimationPlayer
@onready var wind_sound_player: AnimationPlayer = $Background/WindSoundPlayer
@onready var bounce_to_left: Area2D = $BounceToLeft
@onready var bounce_to_right: Area2D = $BounceToRight
@onready var spawn_debris_fx: Node = $SpawnDebrisFX
@onready var boss_bounce_player: AudioStreamPlayer = $BounceBossBack/BossBouncePlayer


signal shoot_up_house


func _ready() -> void:
	connect("shoot_up_house", _shoot_up_house)
	# Set camera lock
	get_node_or_null("Player/Camera").set_screen_lock(0, 1920, 135, 1129)
	get_node_or_null("Player/Camera").set_zoom(Vector2(1,1))

	# Player ost
	music_player.play("stage01_track_copyright")


func _shoot_up_house() -> void:
	animation_player.play("shoot_up")
	wind_sound_player.play("wind_sound")
	get_node_or_null("Player/Camera").set_screen_lock(-200, 2200, 0, -1300)
	get_node_or_null("Player/Camera").zoom_permanent(Vector2(-0.2, -0.2))
	for pos in spawn_debris_fx.get_children():
		var debris = DEBRIS_UP.instantiate()
		debris.position = pos.position
		add_child(debris)
	# get_node_or_null("Player/Camera").set_screen_lock(-20000, 220000, -100000, 300000)
	# get_node_or_null("Player/Camera").zoom_permanent(Vector2(-0.8, -0.8))


func _on_debris_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if get_node_or_null("DebrisArea2D/NoDoor"):
			body._push_x_direct_old(-600)
			var debris = DEBRIS.instantiate()
			debris.position = $DebrisMarker2D.position
			add_child(debris)
			debris_animation_player.play("break_in")
			await get_tree().create_timer(0.1).timeout
			no_door.queue_free()
		else:
			body._push_x_direct_old(-600)


func _on_bounce_to_left_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if !body.is_jump_spawn:
			body._push_direct(Vector2(-200, -500))
			body.is_jump_spawn = true



func _on_bounce_to_right_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if !body.is_jump_spawn:
			body._push_direct(Vector2(200, -500))
			body.is_jump_spawn = true


func _on_helicop_spawn_body_entered(body: Node2D) -> void:
	print_rich("[color=brown][b]HeliSpawn![/b][/color]")
	if body.is_in_group("enemy"):
		body.is_jump_spawn = true
		var tween = get_tree().create_tween()
		tween.tween_property(body, "position", Vector2(1900, 288), 1).set_trans(Tween.TRANS_CUBIC)


func _on_bounce_boss_back_body_entered(body: Node2D) -> void:
	if body.is_in_group("boss"):
		if body.hp_bar.get_hp() <= 0:
			return
		boss_bounce_player.stream = BOSS_BOUNCE_SFX
		boss_bounce_player.pitch_scale = randf_range(0.8, 1.2)
		boss_bounce_player.play()

		body.animation_player.play("idle")

		if body.position.x > 900:
			body._push_direct(Vector2(-200, -200))
		else:
			body._push_direct(Vector2(200, -200))
			
