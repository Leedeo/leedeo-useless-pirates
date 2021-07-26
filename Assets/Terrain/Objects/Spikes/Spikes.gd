extends Area2D

func _on_Spikes_body_entered(body):
	if body.is_in_group("Player"):
		body.damage_ctrl(5) # Llamamos a la función damage_ctrl del player y le aplicamos 5 de daño.
