extends KinematicBody2D
class_name BasicEnemy # Le damos un nombre de clase para que otros enemigos puedan heredar de esta.

onready var camera : Camera2D = get_tree().get_nodes_in_group("Camera")[0] # Referencia a la cámara.

const FLOOR = Vector2(0, -1)
const GRAVITY = 16

export(int, 1, 10) var health : int = 3

onready var motion : Vector2 = Vector2.ZERO
onready var can_move : bool = true
onready var direcion : int = 1

const MIN_SPEED = 32
const MAX_SPEED = 64
var speed : int

func _ready() -> void:
	get_node("AnimationPlayer").play("Run")


func _process(_delta) -> void:
	patrol_ctrl()
	attack_ctrl()
	
	if can_move: # Solo si can_move es igual a true es que el enemigo va a llamar a la función motion_ctrl.
		motion_ctrl()


func patrol_ctrl() -> void:
	if get_node("Raycast/Patrol").is_colliding():
		if get_node("Raycast/Patrol").get_collider().is_in_group("Player"):
			speed = MAX_SPEED
		else:
			speed = MIN_SPEED
	else:
		speed = MIN_SPEED


func attack_ctrl() -> void: # Función creada para controlar el ataque del enemigo.
	if get_node("Raycast/Attack").is_colliding():
		if get_node("Raycast/Attack").get_collider().is_in_group("Player"):
			can_move = false
			get_node("AnimationPlayer").play("Attack")

func motion_ctrl() -> void:
	if direcion == 1: # Vamos a invertir los sprites en función de la dirección.
		get_node("Sprite").flip_h = true
	else:
		get_node("Sprite").flip_h = false
	
	# Si el enemigo colisiona con una pared o el raycast para detectar un precipicio no colisiona, entonces invertirá su dirección.
	if is_on_wall() or not get_node("Raycast/Ground").is_colliding():
		direcion *= -1
		get_node("Raycast").scale.x *= -1
	
	motion.y += GRAVITY
	motion.x = speed * direcion
	
	motion = move_and_slide(motion, FLOOR)


func damage_ctrl(damage) -> void:
	match can_move:
		true:
			if health > 0:
				health -= damage # Parámetro para definir la cantidad de vida que se elimina.
				get_node("AnimationPlayer").play("Hit")
			else:
				get_node("AnimationPlayer").play("Dead Hit")


func _on_AnimationPlayer_animation_started(anim_name): # Señal enviada cuando inicia X animación.
	match anim_name:
		"Hit":
			can_move = false # Bloqueamos el movimiento
			camera.screen_shake(0.7, 0.8, 100)
		"Attack": # El enemigo solo va a quitar vida al player cuando inicia la animación.
			get_node("Raycast/Attack").get_collider().damage_ctrl(1)
		"Dead Hit":
			get_node("SoundDead").play()


func _on_AnimationPlayer_animation_finished(anim_name): # Señal enviada cuando finaliza X animación.
	match anim_name:
		"Hit":
			if health > 0:
				can_move = true # Si la vida es superior a 0, lo volvemos activar al terminar la animación.
				get_node("AnimationPlayer").play("Run")
			else:
				get_node("AnimationPlayer").play("Dead Hit") # De lo contrario reproducimos la animación de muerte.
		"Attack": # Y cuando termina de atacar, regresamos al enemigo a la normalidad.
			can_move = true
			get_node("AnimationPlayer").play("Run")
		"Dead Hit":
			queue_free() # Al terminar la animación, se elimina.
