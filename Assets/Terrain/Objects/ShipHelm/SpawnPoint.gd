extends Area2D

func _on_SpawnPoint_body_entered(body):
	if body.is_in_group("Player"): # Cuando el personaje entra en el área se cambia el punto de spawn.
		get_node("AnimatedSprite").play("Turn")
		get_node("Sound").play()
		GLOBAL.spawn_point = global_position


func _on_AnimatedSprite_animation_finished():
	get_node("AnimatedSprite").play("Idle")
