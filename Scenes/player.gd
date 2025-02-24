extends CharacterBody2D


const SPEED = 1500.0
const JUMP_VELOCITY = -400.0
var direction = "none"
@onready var animations = $AnimationPlayer

func _physics_process(delta: float) -> void:

	var direction_y := Input.get_axis("up", "down")

	if direction_y:
		velocity.y = direction_y * SPEED
		if Input.is_action_pressed("boost"):
			velocity.y = direction_y * (SPEED + (SPEED / 2))
		else:
			velocity.y = direction_y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction_x := Input.get_axis("left", "right")

	if direction_x:
		velocity.x = direction_x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
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
