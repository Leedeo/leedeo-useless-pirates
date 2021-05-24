extends KinematicBody2D

const SPEED = 128
const FLOOR = Vector2(0, -1)
const GRAVITY = 16
const JUMP_HEIGHT = 384
const BOUNCING_JUMP = 112 # Esta constante es para definir la fuerza de rebote en la pared.
const CAST_WALL = 10 # Esta constante es para definir la distancia de colisión con la pared.
const CAST_ENEMY = 22 # Esta constante es para definir la distancia de colisión con los enemigos.
onready var motion : Vector2 = Vector2.ZERO
var can_move : bool # Esta variable es para comprobar si el personaje puede moverse.

""" STATE MACHINE """
var playback : AnimationNodeStateMachinePlayback


func _ready():
	playback = $AnimationTree.get("parameters/playback") # Obtenemos la referencia al parámetro playback del nodo AnimationTree.
	playback.start("Idle") # Iniciamos en el estado Idle.
	$AnimationTree.active = true # Y activamos el AnimationTree


func _process(_delta):
	motion_ctrl()
	direction_ctrl()
	jump_ctrl()
	attack_ctrl()


func get_axis() -> Vector2:
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	return axis


# Al separar los comportamientos en distintas funciones, la función de movimiento ha quedado mucho más limpia y comprensible a simple vista.
func motion_ctrl():
	motion.y += GRAVITY
	
	if can_move: # Aquí se indica que solo podrá moverse si can_move es igual a true.
		motion.x =  get_axis().x * SPEED
		
		if get_axis().x == 0:
			playback.travel("Idle")
		else:
			playback.travel("Run")
	
		match playback.get_current_node():
			"Idle":
				motion.x =  0
				$Particles.emitting = false
			"Run":
				$Particles.emitting = true
				
		if get_axis().x == 1:
			$Sprite.flip_h = false
		elif get_axis().x == -1:
			$Sprite.flip_h = true
			
	motion = move_and_slide(motion, FLOOR)


# Como es probable que se vayan agregando componentes creamos esta función para mantener cierto orden en el código e indicar la dirección de ciertos elementos.
func direction_ctrl(): 
	match $Sprite.flip_h:
		true:
			$RayWall.cast_to.x = -CAST_WALL
			$RayEnemy.cast_to.x = -CAST_ENEMY
		false:
			$RayWall.cast_to.x = CAST_WALL
			$RayEnemy.cast_to.x = CAST_ENEMY


# Separamos la función de salto igualmente para mantener orden en el código y facilitar así la lectura.
func jump_ctrl():
	match is_on_floor():
		true: # Aquí comprobamos si el personaje se encuentra tocando el suelo.
			can_move = true # En caso afirmativo, can_move es igual a true.
			$RayWall.enabled = false # Y el Raycast permanece inactivo.
		
			if Input.is_action_just_pressed("jump"):
				$Sounds/Jump.play()
				motion.y -= JUMP_HEIGHT
			
		false: # Aquí comprobamos si el personaje no se encuentra tocando el suelo.
			$Particles.emitting = false # En caso negativo, se desactiva la emisión de partículas.
			$RayWall.enabled = true # Y se activa el Raycast.
		
			if motion.y < 0:
				playback.travel("Jump")
			else:
				playback.travel("Fall")
			
			if $RayWall.is_colliding(): # He creado esta condición para preguntar si el nodo está colisionando.
				can_move = false # Y en caso afirmativo, can_move es igual a false.
				
				var col = $RayWall.get_collider() # Creo esta variable para guardar las colisiones.
			
				# En este condicional se está comprobando si el personaje se encuentra tocando la pared y pulsamos la tecla de salto.
				if col.is_in_group("Wall") and Input.is_action_just_pressed("jump"):
					$Sounds/Jump.play()
					motion.y -= JUMP_HEIGHT
					
					if $Sprite.flip_h:
						motion.x += BOUNCING_JUMP
						$Sprite.flip_h = false
					else:
						motion.x -= BOUNCING_JUMP
						$Sprite.flip_h = true


# Creamos una función para controlar el ataque del personaje.
func attack_ctrl():
	if is_on_floor():
		if get_axis().x == 0 and Input.is_action_just_pressed("attack"):
			match playback.get_current_node():
				"Idle":
					playback.travel("Attack-1")
					$Sounds/Sword.play()
				"Attack-1":
					playback.travel("Attack-2")
					$Sounds/Sword.play()
				"Attack-2":
					playback.travel("Attack-3")
					$Sounds/Sword.play()
	
	if playback.get_current_node() == "Attack-1" or playback.get_current_node() == "Attack-2" or playback.get_current_node() == "Attack-3":
		$RayEnemy.enabled = true
	else:
		$RayEnemy.enabled = false
	
	# Código temporal para comprobar el funcionamiento.
	var col = $RayEnemy.get_collider() # Mismo procedimiento que el Raycast de la pared.
	
	if $RayEnemy.is_colliding() and col.is_in_group("Enemy"):
		col.queue_free()
