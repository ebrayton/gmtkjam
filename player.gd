extends KinematicBody2D

var sprite_node

var input_direction = 0
var direction = 0

var speed = Vector2()
var velocity = Vector2()

const MAX_SPEED = 700
const ACCELERATION = 2600
const DECELERATION = 5000

var jump_count = 0
const MAX_JUMP_COUNT = 2

const JUMP_FORCE = 1000
const GRAVITY = 2800
const MAX_FALL_SPEED = 1400


func _ready():
	set_process(true)
	set_process_input(true)
	sprite_node = get_node("Sprite")


func _input(event):
	# NOTE: useful for events that need to fire when a key is pressed (jumping/shooting)
	# instead of things that need to happen constantly (while holding a key) (walking/movement)
	# those should be in _process
	if jump_count < MAX_JUMP_COUNT and event.is_action_pressed("jump"):
		speed.y = -JUMP_FORCE # in Godot, +y is down, -y is up
		jump_count += 1


func _process(delta):
	# INPUT
	if input_direction:
		direction = input_direction
	
	if  Input.is_action_pressed("move_left") and  Input.is_action_pressed("move_right"):
		input_direction = 0
	elif Input.is_action_pressed("move_left"):
		input_direction = -1
		sprite_node.set_flip_h(true) # if it starts at the right)
	elif Input.is_action_pressed("move_right"):
		input_direction = 1
		sprite_node.set_flip_h(false)
	else:
		input_direction = 0
	
	# MOVEMENT
	if input_direction == - direction:
		speed.x /= 3
	if input_direction:
		speed.x += ACCELERATION * delta
	else:
		speed.x -= DECELERATION * delta
	speed.x = clamp(speed.x, 0, MAX_SPEED)
	
	speed.y += GRAVITY * delta
	if speed.y > MAX_FALL_SPEED:
		speed.y = MAX_FALL_SPEED
	
	velocity.x = speed.x * delta * direction
	velocity.y = speed.y * delta
	var movement_remainder = move(velocity)
	
	if is_colliding():
		var normal = get_collision_normal()
		var final_movement = normal.slide(movement_remainder)  # projects movement_remainder onto normal? 
															   # Removes the part of the movement that causes
															   # the collision with the collider's normal
		speed = normal.slide(speed) # must reset so y doesn't continue to accumulate
		move(final_movement)
		
		if normal == Vector2(0, -1):  # flat ground (how to get anything that's not vertical?)
			jump_count = 0
	
	
	