extends ParallaxLayer


@export var MIN_SPEED: int = 500
@export var MAX_SPEED: int = 3000
var actual_speed: int


func _ready() -> void:
	actual_speed = randi_range(MIN_SPEED, MAX_SPEED)


func _process(delta):
	# if not $"..".is_freeze:
	motion_offset.y += actual_speed * delta
