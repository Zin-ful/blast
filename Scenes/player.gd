extends CharacterBody2D


const SPEED = 1500.0
const ACCELERATION = 2000.0  # How fast the speed increases
const DECELERATION = 200.0  # How fast the speed decreases
const MAX_SPEED = 1500.0  # Maximum movement speed
const DIRECTION_CHANGE_FORCE = 6000.0  # Higher acceleration when switching directions

var direction = "none"
@onready var animations = $AnimationPlayer

func _physics_process(delta: float) -> void:
	var direction_y := Input.get_axis("up", "down")
	var target_speed_y = 0.0  # Default target speed (for deceleration)
	
	if direction_y:
		var speed_multiplier = 1.0
		if Input.is_action_pressed("boost"):
			speed_multiplier = 3.0  # Boost increases speed
		target_speed_y = direction_y * MAX_SPEED * speed_multiplier
		
		# If changing direction, apply a higher acceleration force
		if sign(direction_y) != sign(velocity.y) and velocity.y != 0:
			velocity.y = move_toward(velocity.y, target_speed_y, DIRECTION_CHANGE_FORCE * delta)
		else:
			velocity.y = move_toward(velocity.y, target_speed_y, ACCELERATION * delta)
	else:
		velocity.y = move_toward(velocity.y, 0, DECELERATION * delta)

	# Handle horizontal movement the same way
	var direction_x := Input.get_axis("left", "right")
	var target_speed_x = 0.0  # Default target speed (for deceleration)

	if direction_x:
		var speed_multiplier = 1.0
		target_speed_x = direction_x * MAX_SPEED
		if Input.is_action_pressed("boost"):
			speed_multiplier = 3.0  # Boost increases speed
		target_speed_x = direction_x * MAX_SPEED * speed_multiplier
		# If changing direction, apply a higher acceleration force
		if sign(direction_x) != sign(velocity.x) and velocity.x != 0:
			velocity.x = move_toward(velocity.x, target_speed_x, DIRECTION_CHANGE_FORCE * delta)
		else:
			velocity.x = move_toward(velocity.x, target_speed_x, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)

	move_and_slide()
	animUpdate()
func animUpdate():
	if velocity.length() == 0:
		animations.play("return_" + direction)
		await animations.animation_finished
		animations.stop()
	else:
		if velocity.x < 0: 
			direction = "left"
		elif velocity.x > 0: 
			direction = "right"
		elif velocity.y < 0: 
			direction = "up"
		elif velocity.y > 0: 
			direction = "down"
		animations.play("turn_" + direction)
		await animations.animation_finished
		animations.stop()
