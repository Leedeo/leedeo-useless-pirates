extends Node2D

var fire_spirit : PackedScene = load("res://Assets/Characters/Player/Spirit.tscn")

func _ready():
	GLOBAL.coins = 0
	$MobilePlatform/AnimationPlayer.play("Move")
	
	if GLOBAL.level_start: # Si el nivel acaba de iniciar y el player se encuentra en el árbol de escenas.
		GLOBAL.spawn_point = $Player.global_position # Entonces el punto de spawn es igual a la posición donde colocásemos al player.
	
	$Player.global_position = GLOBAL.spawn_point # Y para que esto se cumpla cada vez que se inicie el nivel la posición del player debe ser igual al punto de spawn.

func _process(_delta):
	if GLOBAL.powerful_shot and get_tree().get_nodes_in_group("Spirit").size() <= 0:
		add_child(fire_spirit.instance())
