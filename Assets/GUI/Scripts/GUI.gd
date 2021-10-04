extends CanvasLayer

onready var player : KinematicBody2D = get_tree().get_nodes_in_group("Player")[0] # Referencia a la cámara.


func _ready():
	$AnimationPlayer.play("Fade-In") # Reproducimos la animación de inicio.
	$TextureProgress.max_value = player.health


func _process(_delta):
	if is_instance_valid(player):
		$TextureProgress.value = player.health
		$ScoreContainer/Label.text = str("x ") + str(GLOBAL.coins)


func _on_TextureProgress_value_changed(value):
	if value <= 0:
		$AnimationPlayer.play("Fade-Out") # Reproducimos la animación de Fade-Ou.


func _on_AnimationPlayer_animation_started(anim_name):
	match anim_name:
		"Fade-Out": # Cuando inicia esta animación, pausamos el juego.
			get_tree().paused = true
			$Control/VBoxContainer.visible = true # Hacemos visible el texto de Game Over.
			$Sounds/GameOver.play() # Reproducimos la música de Game Over.
		"Fade-In": # Cuando inicia esta animación, ocultamos el texto de Game Over
			$Control/VBoxContainer.visible = false


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Fade-In": # Cuando termina de ocultarse, quitamos la pausa.
			get_tree().paused = false


func _on_GameOver_finished(): # Cuando termina la música se reinicia la escena.
	
	# Usamos call_deferred para hacer una llamada segura y que no arroje advertencias.
	get_tree().call_deferred("reload_current_scene")
	
	# Si el personaje ha muerto ya no es la primera vez que inicia el nivel, así que level_start es igual a false, si esto fuera un juego con más niveles cada vez que terminásemos uno al terminar deberíamos regresar esta variable a true.
	GLOBAL.level_start = false
