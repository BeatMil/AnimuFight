extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

const SPEED = 300.0
const JUMP_VELOCITY = 900
const FRICTION = 0.06

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity_power = 30

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity_power

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		pass
		# velocity.x = move_toward(velocity.x, 0, 0.9)
		lerp_velocity_x()

	move_and_slide()


## Godot said this built-in is better for performance (me no understand tho...)
func _unhandled_key_input(event: InputEvent) -> void:
	## LP (Light Punch) can also change direction while lping
	if event.is_action_pressed("lp"):
		_lp()


func _lp() ->  void:
	animation_player.play("lp1")


func lerp_velocity_x():
	velocity = velocity.lerp(Vector2(0, velocity.y), FRICTION)


func _push_x(pixel: int) -> void:
	print_rich("pixel: [color=green][b]%s[/b][/color] Nyaaa > w <"%pixel)
	var multiplier = 10
	velocity += Vector2(pixel*multiplier, 0)
