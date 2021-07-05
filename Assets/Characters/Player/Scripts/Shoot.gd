extends Area2D

var direction : int
onready var can_move : bool = true

func _ready() -> void:
	$AnimationPlayer.play("Shoot")
	$Sounds/Shoot.play()


func _process(delta) -> void:
	# Su única función es moverse en una dirección X, la cual es definida por quien dispara.
	if can_move:
		global_position.x += direction * delta


func _on_VisibilityNotifier2D_screen_exited():
	queue_free() # Si sale de pantalla, el disparo se elimina.


func _on_Shoot_body_entered(body): # El área envía la señal body_entered.
	if body.is_in_group("Enemy"): # Si el cuerpo pertenece al grupo Enemy.
		body.damage_ctrl(1) # Se llama a la función damage_ctrl de los enemigos.
		$AnimationPlayer.play("Explosion")
		$Sounds/Explosion.play() # Añadimos el sonido de explosión.
		
	elif body.is_in_group("Wall"): # Si el cuerpo pertenece al grupo Wall.
		$AnimationPlayer.play("Explosion")
		$Sounds/Explosion.play() # Añadimos el sonido de explosión.


func _on_AnimationPlayer_animation_started(anim_name):
	match anim_name:
		"Explosion":
			can_move = false


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Explosion":
			queue_free() # Se elimina el disparo.
