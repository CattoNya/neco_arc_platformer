extends KinematicBody2D

export var speed = Vector2(150.0, 350.0)
onready var gravity = ProjectSettings.get("physics/2d/default_gravity")

const FLOOR_NORMAL = Vector2.UP

var _velocity = Vector2.ZERO

const FLOOR_DETECT_DISTANCE = 20.0
onready var platform_detector = $RayCast2D
onready var sprite = $AnimatedSprite

func get_direction ():
	return Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		-1 if is_on_floor() and Input.is_action_just_pressed("ui_accept") else 0
	)

func calculate_move_velocity (
		linear_velocity,
		direction,
		speed,
		is_jump_interrupted
	):
	var velocity = linear_velocity
	velocity.x = speed.x * direction.x
	if direction.y != 0.0:
		velocity.y = speed.y * direction.y
	if is_jump_interrupted:
		# Decrease the Y velocity by multiplying it, but don't set it to 0
		# as to not be too abrupt.
		velocity.y *= 0.6
	return velocity
	
func do_animations ():
	pass
	if is_on_floor():
		if abs(_velocity.x) > 0.1:
			sprite.animation = "walk"
		else:
			sprite.animation = "idle"
	else:
		if _velocity.y > 0:
			sprite.animation = "fall"
		else:
			sprite.animation = "jump"


# _physics_process is called after the inherited _physics_process function.
# This allows the Player and Enemy scenes to be affected by gravity.
func _physics_process(delta):
	_velocity.y += gravity * delta
	var direction = get_direction()
	
	var is_jump_interrupted = Input.is_action_just_released("jump") and _velocity.y < 0.0
	_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)
	
	var snap_vector = Vector2.ZERO
	if direction.y == 0.0:
		snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE
	var is_on_platform = platform_detector.is_colliding()
	_velocity = move_and_slide_with_snap(
		_velocity, snap_vector, FLOOR_NORMAL, not is_on_platform, 4, 0.9, false
	)
	
	if direction.x != 0:
		if direction.x > 0:
			if ( sprite.scale.x < 0 ): sprite.scale.x *= -1
		else:
			if ( sprite.scale.x >= 0 ): sprite.scale.x *= -1
			
	do_animations()
