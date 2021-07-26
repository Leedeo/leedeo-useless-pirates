extends CanvasLayer

onready var player : KinematicBody2D = get_tree().get_nodes_in_group("Player")[0] # Referencia a la cámara.


func _ready():
	get_node("AnimationPlayer").play("Fade-In") # Reproducimos la animación de inicio.
	get_node("TextureProgress").max_value = player.health


func _process(_delta):
	if is_instance_valid(player):
		get_node("TextureProgress").value = player.health
		get_node("ScoreContainer/Label").text = str("x ") + str(GLOBAL.coins)


func _on_TextureProgress_value_changed(value):
	if value <= 0:
		get_node("AnimationPlayer").play("Fade-Out") # Reproducimos la animación de Fade-Ou.


func _on_AnimationPlayer_animation_started(anim_name):
	match anim_name:
		"Fade-Out": # Cuando inicia esta animación, pausamos el juego.
			get_tree().paused = true
			get_node("Control/VBoxContainer").visible = true # Hacemos visible el texto de Game Over.
			get_node("Sounds/GameOver").play() # Reproducimos la música de Game Over.
		"Fade-In": # Cuando inicia esta animación, ocultamos el texto de Game Over
			get_node("Control/VBoxContainer").visible = false


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Fade-In": # Cuando termina de ocultarse, quitamos la pausa.
			get_tree().paused = false


func _on_GameOver_finished(): # Cuando termina la música se reinicia la escena.
	# Usamos call_deferred para hacer una llamada segura y que no arroje advertencias.
	get_tree().call_deferred("reload_current_scene")
