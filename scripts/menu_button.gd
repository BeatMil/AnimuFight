extends Button


@onready var cursor_pos: Marker2D = $CursorPos


func _ready() -> void:
	focus_entered.connect(move_menu_cursor_here)


func move_menu_cursor_here() -> void:
	%MenuCursor.move_to(cursor_pos.global_position)
