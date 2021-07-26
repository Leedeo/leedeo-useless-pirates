extends KinematicBody2D

# El principio de la refactorización consiste en cambiar el código sin cambiar el comportamiento para facilitar la lectura y por lo tanto la tarea de actualizar el software.

const SPEED = 128
const FLOOR = Vector2(0, -1)
const GRAVITY = 16
const JUMP_HEIGHT = 384
const BOUNCING_JUMP = 112 # Esta constante es para definir la fuerza de rebote en la pared.

var motion : Vector2 = Vector2.ZERO
var can_move : bool # Esta variable es para comprobar si el personaje puede moverse.

var immunity : bool = false # Esto es para crear el estado de inmunidad en el player.
var health : int = 5 # Con esta variable contabilizamos la salud del player.

""" STATE MACHINE """
var playback : AnimationNodeStateMachinePlayback


func _ready():
	playback = get_node("AnimationTree").get("parameters/playback") # Obtenemos la referencia al parámetro playback del nodo AnimationTree.
	playback.start("Idle") # Iniciamos en el estado Idle.
	get_node("AnimationTree").active = true # Y activamos el AnimationTree


func _process(_delta):
	motion_ctrl()
	jump_ctrl()
	attack_ctrl()


# Al separar los comportamientos en distintas funciones, la función de movimiento ha quedado mucho más limpia y comprensible a simple vista.
func motion_ctrl() -> void:
	motion.y += GRAVITY
	
	if can_move: # Aquí se indica que solo podrá moverse si can_move es igual a true.
		motion.x =  GLOBAL.get_axis().x * SPEED
		
		if GLOBAL.get_axis().x == 0:
			playback.travel("Idle")
		elif GLOBAL.get_axis().x == 1:
			playback.travel("Run")
			get_node("Sprite").flip_h = false
		elif GLOBAL.get_axis().x == -1:
			playback.travel("Run")
			get_node("Sprite").flip_h = true
		
		match playback.get_current_node():
			"Idle":
				motion.x =  0
				get_node("Particles").emitting = false
			"Run":
				get_node("Particles").emitting = true
				
	# Como he añadido los Raycast dentro de un position únicamente tenemos que cambiar la escala del nodo padre para invertir sus nodos hijos. Al ser un código más sencillo se puede prescindir de la función direction_ctrl() creada anteriormente.
	match get_node("Sprite").flip_h:
		true:
			get_node("Raycast").scale.x = -1
		false:
			get_node("Raycast").scale.x = 1
			
	motion = move_and_slide(motion, FLOOR)
	
	var slide_count = get_slide_count() # Retorna el número de veces que el cuerpo está colisionando.
	
	if slide_count: # Si fuera superior a 0 es igual a true.
		# Así que guardamos en una variable el objeto colisionado y en otra su collider.
		var collision = get_slide_collision(slide_count - 1)
		var collider = collision.collider
		
		# Si pertenece al grupo Platform y presionamos abajo, desactivamos el collider del player y activamos el timer.
		if collider.is_in_group("Platform") and Input.is_action_just_pressed("ui_down"):
			get_node("Collision").disabled = true
			get_node("Timer").start()


# Separamos la función de salto igualmente para mantener orden en el código y facilitar así la lectura.
func jump_ctrl() -> void:
	match is_on_floor():
		true: # Aquí comprobamos si el personaje se encuentra tocando el suelo.
			can_move = true # En caso afirmativo, can_move es igual a true.
		
			if Input.is_action_just_pressed("jump"):
				get_node("Sounds/Jump").play()
				motion.y -= JUMP_HEIGHT
			
		false: # Aquí comprobamos si el personaje no se encuentra tocando el suelo.
			get_node("Particles").emitting = false # En caso negativo, se desactiva la emisión de partículas.
		
			if motion.y < 0:
				playback.travel("Jump")
			else:
				playback.travel("Fall")
			
			if get_node("Raycast/Wall").is_colliding(): # Tenemos que comprobar primero si ha colisionado, de lo contrario arrojaría un error.
				
				var body = get_node("Raycast/Wall").get_collider() # Creo esta variable para guardar las colisiones.
			
				if body.is_in_group("Terrain"): # Comprobamos si el personaje se encuentra tocando la pared.
					can_move = false # Y en caso afirmativo, can_move es igual a false. Movemos esta comprobación aquí para que solo bloquee el movimiento si colisiona con una pared.
					
					if Input.is_action_just_pressed("jump"):
						get_node("Sounds/Jump").play()
						motion.y -= JUMP_HEIGHT
						
						if get_node("Sprite").flip_h:
							motion.x += BOUNCING_JUMP
							get_node("Sprite").flip_h = false
						else:
							motion.x -= BOUNCING_JUMP
							get_node("Sprite").flip_h = true


# Creamos una función para controlar el ataque del personaje.
func attack_ctrl() -> void:
	var body = get_node("Raycast/Hit").get_collider() # Utilizamos el mismo procedimiento que para detectar la colisión con la pared.
	
	if is_on_floor():
		if GLOBAL.get_axis().x == 0 and Input.is_action_just_pressed("attack"):
			match playback.get_current_node():
				"Idle":
					playback.travel("Attack-1")
					get_node("Sounds/Sword").play()
				"Attack-1":
					playback.travel("Attack-2")
					get_node("Sounds/Sword").play()
				"Attack-2":
					playback.travel("Attack-3")
					get_node("Sounds/Sword").play()
					
			if get_node("Raycast/Hit").is_colliding(): 
				if body.is_in_group("Enemy"):
					body.damage_ctrl(3)


# Creamos la función para controlar el daño recibido.
func damage_ctrl(damage : int) -> void:
	match immunity:
		false: # Si el personaje no se encuentra en estado de inmunidad debe recibir daño.
			health -= damage # Se resta 1 a la salud.
			get_node("AnimationPlayer").play("Hit") # Se reproduce la animación de daño.
			get_node("Sounds/Hit").play() # Se reproduce el sonido de daño.
			immunity = true # Y por un momento se hace inmune.


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Hit":
			immunity = false # # Y cuando termina deja de ser inmune.


func _on_Timer_timeout():
	# Cuando el tiempo termina, se activa nuevamente el collider, es una forma de hacer esto.
	get_node("Collision").disabled = false
