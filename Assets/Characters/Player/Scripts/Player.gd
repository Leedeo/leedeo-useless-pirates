extends KinematicBody2D

const SPEED = 128
const FLOOR = Vector2(0, -1)
const GRAVITY = 16
const JUMP_HEIGHT = 384
const BOUNCING_JUMP = 112 # He creado esta constante para definir la fuerza de rebote en la pared.
const CAST_WALL = 10 # Esta constante es para definir la distancia de colisión con la pared.
onready var motion : Vector2 = Vector2.ZERO
var can_move : bool # He creado esta variable para comprobar si el personaje puede moverse.


func _process(_delta):
	motion_ctrl()


func get_axis() -> Vector2:
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	return axis


func motion_ctrl():
	motion.y += GRAVITY
	
	if can_move: # Aquí indico que solo podrá moverse si can_move es igual a true.
		if get_axis().x == 1:
			$Raycast.cast_to.y = CAST_WALL # Esto es para controlar la dirección del Raycast.
			$AnimatedSprite.flip_h = false
		elif get_axis().x == -1:
			$Raycast.cast_to.y = -CAST_WALL # Aquí invierto la dirección del Raycast.
			$AnimatedSprite.flip_h = true
		
		if get_axis().x != 0:	
			motion.x =  get_axis().x * SPEED
		else:
			motion.x = 0
	
	if is_on_floor():
		can_move = true
		
		if get_axis().x != 0:
			$AnimatedSprite.play("Run")
			$Particles.emitting = true # Esto es para emitir las partículas cuando se encuentra en movimiento.
		else:
			$AnimatedSprite.play("Idle")
			$Particles.emitting = false
		
		if Input.is_action_just_pressed("ui_accept"):
			$Jump.play()
			motion.y -= JUMP_HEIGHT
	else:
		$Particles.emitting = false
		
		if motion.y < 0:
			$AnimatedSprite.play("Jump")
		else:
			$AnimatedSprite.play("Fall")
			
		if $Raycast.is_colliding(): # He creado esta condición para preguntar si el nodo esta colisionando.
			can_move = false # He indico que can_move es igual a false.
			
			var col = $Raycast.get_collider() # Creo esta variable para guardar las colisiones.
		
			if col.is_in_group("Wall") and Input.is_action_just_pressed("ui_accept"):
				$Jump.play()
				motion.y -= JUMP_HEIGHT
				
				if $AnimatedSprite.flip_h:
					motion.x += BOUNCING_JUMP
					$AnimatedSprite.flip_h = false
				else:
					motion.x -= BOUNCING_JUMP
					$AnimatedSprite.flip_h = true
				
	motion = move_and_slide(motion, FLOOR)
