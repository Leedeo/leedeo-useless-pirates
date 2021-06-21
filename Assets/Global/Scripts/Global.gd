extends Node

# Como vamos a poner esta función dentro de un script global, entonces hay que hacer los cambios pertinentes en el script del player.
func get_axis() -> Vector2: 
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	return axis
