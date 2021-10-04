extends Node
var level_start : bool = true # Para comprobar si es la primera vez que iniciamos el nivel
var spawn_point : Vector2 # Para guardar la posición.
var coins : int = 0

var powerful_shot : bool = false # Creo esta variable para controlar el disparo con power up.

# Como vamos a poner esta función dentro de un script global, entonces hay que hacer los cambios pertinentes en el script del player.
func get_axis() -> Vector2: 
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	return axis
