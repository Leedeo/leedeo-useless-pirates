extends KinematicBody2D

const SPEED = 128
const FLOOR = Vector2(0, -1)
const GRAVITY = 16
const JUMP_HEIGHT = 384
onready var motion = Vector2.ZERO


func _process(_delta):
	motion_ctrl()


func get_axis() -> Vector2:
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	return axis


func motion_ctrl():
	motion.y += GRAVITY
	
	if get_axis().x == 1:
		$AnimatedSprite.flip_h = false
	elif get_axis().x == -1:
		$AnimatedSprite.flip_h = true
	
	if get_axis().x != 0:
		motion.x =  get_axis().x * SPEED
	else:
		motion.x = 0
	
	if is_on_floor():
		if get_axis().x != 0:
			$AnimatedSprite.play("Run")
		else:
			$AnimatedSprite.play("Idle")
		
		if Input.is_action_just_pressed("ui_accept"):
			$Jump.play()
			motion.y -= JUMP_HEIGHT
	else:
		if motion.y < 0:
			$AnimatedSprite.play("Jump")
		else:
			$AnimatedSprite.play("Fall")
	
	motion = move_and_slide(motion, FLOOR)
