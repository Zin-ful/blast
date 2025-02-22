extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var ship_animation_original = $ship_animation_original


func _physics_process(delta: float) -> void:

	var direction_y := Input.get_axis("up", "down")

	if direction_y:
		velocity.y = direction_y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
		
	if direction_y > 0.0:
		ship_animation_original.flip_v = true
	elif direction_y < 0.0:
		ship_animation_original.flip_v = false
	else:
		pass
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction_x := Input.get_axis("left", "right")

	if direction_x:
		velocity.x = direction_x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if direction_x > 0.0:
		ship_animation_original.flip_h = direction_x
	elif direction_x < 0.0:
		ship_animation_original.flip_h = direction_x
	else:
		pass
	move_and_slide()
