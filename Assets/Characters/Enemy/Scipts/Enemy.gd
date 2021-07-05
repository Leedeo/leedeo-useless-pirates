extends KinematicBody2D

onready var camera : Camera2D = get_tree().get_nodes_in_group("Camera")[0] # Referencia a la cámara.

const FLOOR = Vector2(0, -1)
const GRAVITY = 16

export(int, 1, 10) var health : int = 3

onready var motion : Vector2 = Vector2.ZERO
onready var can_move : bool = true
onready var direcion : int = 1
const SPEED = 48

func _ready() -> void:
	$AnimationPlayer.play("Run")


func _process(_delta) -> void:
	if can_move: # Solo si can_move es igual a true es que el enemigo va a llamar a la función motion_ctrl.
		motion_ctrl()


func motion_ctrl() -> void:
	if direcion == 1: # Vamos a invertir los sprites en función de la dirección.
		$Sprite.flip_h = true
	else:
		$Sprite.flip_h = false
	
	# Si el enemigo colisiona con una pared o el raycast para detectar un precipicio no colisiona, entonces invertirá su dirección.
	if is_on_wall() or not $Raycast/Ground.is_colliding():
		direcion *= -1
		$Raycast.scale.x *= -1
	
	motion.y += GRAVITY
	motion.x = SPEED * direcion
	
	motion = move_and_slide(motion, FLOOR)


func damage_ctrl(damage) -> void:
	if can_move:
		if health > 0:
			health -= damage # Parámetro para definir la cantidad de vida que se elimina.
			$AnimationPlayer.play("Hit")
			print("La vida del enemigo es igual a: " + str(health))
		else:
			$AnimationPlayer.play("Dead Hit")


func _on_AnimationPlayer_animation_started(anim_name): # Señal enviada cuando inicia X animación.
	match anim_name:
		"Hit":
			can_move = false # Bloqueamos el movimiento
			camera.screen_shake(0.5, 0.6, 100)
		"Dead Hit":
			$SoundDead.play()


func _on_AnimationPlayer_animation_finished(anim_name): # Señal enviada cuando finaliza X animación.
	match anim_name:
		"Hit":
			if health > 0:
				can_move = true # Si la vida es superior a 0, lo volvemos activar al terminar la animación.
				$AnimationPlayer.play("Run")
			else:
				$AnimationPlayer.play("Dead Hit") # De lo contrario reproducimos la animación de muerte.
		"Dead Hit":
			queue_free() # Al terminar la animación, se elimina.
