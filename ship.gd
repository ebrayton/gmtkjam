extends KinematicBody2D

var sprite_node

var input_direction = Vector2()
var direction = Vector2()

var speed = Vector2()
var velocity = Vector2()

const MAX_SPEED = 700
const ACCELERATION = 2600
const DECELERATION = 4000


func _ready():
	set_process(true)
	set_process_input(true)
	sprite_node = get_node("Sprite")


func _input(event):
	# NOTE: useful for events that need to fire when a key is pressed (jumping/shooting)
	# instead of things that need to happen constantly (while holding a key) (walking/movement)
	# those should be in _process
	pass


func _process(delta):
	# INPUT
	if input_direction != Vector2(0,0):
		direction = input_direction

	if  Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right"):
		input_direction.x = 0
	elif Input.is_action_pressed("move_left"):
		input_direction.x = -1
		sprite_node.set_flip_h(true)  # if it starts at the right
	elif Input.is_action_pressed("move_right"):
		input_direction.x = 1
		sprite_node.set_flip_h(false)

	if  Input.is_action_pressed("move_up") and Input.is_action_pressed("move_back"):
		input_direction.y = 0
	elif Input.is_action_pressed("move_up"):
		input_direction.y = -1
	elif Input.is_action_pressed("move_back"):
		input_direction.y = 1

	if not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		input_direction.x = 0;
	if not Input.is_action_pressed("move_up") and not Input.is_action_pressed("move_back"):
		input_direction.y = 0

	# MOVEMENT
	if input_direction.x == - direction.x:
		speed.x /= 3
	if input_direction.y == - direction.y:
		speed.y /= 3

	if input_direction.x:
		speed.x += ACCELERATION * delta
	else:
		speed.x -= DECELERATION * delta

	if input_direction.y:
		speed.y += ACCELERATION * delta
	else:
		speed.y -= DECELERATION * delta

	speed.x = clamp(speed.x, 0, MAX_SPEED)
	speed.y = clamp(speed.y, 0, MAX_SPEED)

	velocity.x = speed.x * delta * direction.x
	velocity.y = speed.y * delta * direction.y
	var movement_remainder = move(velocity)

	if is_colliding():
		var normal = get_collision_normal()
		var final_movement = normal.slide(movement_remainder)  # projects movement_remainder onto normal? 
															   # Removes the part of the movement that causes
															   # the collision with the collider's normal
		speed = normal.slide(speed) # must reset so y doesn't continue to accumulate
		move(final_movement)
