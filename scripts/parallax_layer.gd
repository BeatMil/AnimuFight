extends ParallaxLayer


@export var SPEED: int = 1000


func _process(delta):
	# if not $"..".is_freeze:
	motion_offset.y += SPEED * delta
