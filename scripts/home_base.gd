extends Node2D


@onready var player: CharacterBody2D = $Player
@onready var button_hint: Sprite2D = $Desktop/ButtonHint
@onready var move_store_menu: Control = $CanvasLayer/MoveStoreMenu
@onready var big_menu: Control = $CanvasLayer/BigMenu

var is_player_in_store: bool = false


func _ready() -> void:
	# Set Restart
	Settings.current_stage = "res://scenes/home_base.tscn"

	# Set camera
	CameraManager.enable_all_camera()
	CameraManager.player = player
	CameraManager.make_current(0)
	CameraManager.set_zoom(Vector2(1, 1))
	CameraManager.set_screen_lock(0, 1940, 135, 1029)
	CameraManager.set_zoom(Vector2.ONE)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("down") and is_player_in_store:
		big_menu.process_mode = Node.PROCESS_MODE_DISABLED
		move_store_menu.open_menu()


func _on_move_store_area_2d_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		button_hint.texture = InputDetector.get_icon_from_action("down")
		button_hint.visible = true

		is_player_in_store = true
		print("player entered store area")


func _on_move_store_area_2d_2_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		button_hint.visible = false

		is_player_in_store = false
		print("player exited store area")


func _on_move_store_menu_close_store_menu() -> void:
	await get_tree().create_timer(0.2).timeout
	big_menu.process_mode = Node.PROCESS_MODE_ALWAYS
