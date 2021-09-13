extends Node2D

func _ready():
	GLOBAL.coins = 0
	get_node("MobilePlatform/AnimationPlayer").play("Move")
	
	if GLOBAL.level_start: # Si el nivel acaba de iniciar y el player se encuentra en el árbol de escenas.
		GLOBAL.spawn_point = get_node("Player").global_position # Entonces el punto de spawn es igual a la posición donde colocásemos al player.
	
	# Y para que esto se cumpla cada vez que se inicie el nivel la posición del player debe ser igual al punto de spawn.
	get_node("Player").global_position = GLOBAL.spawn_point
