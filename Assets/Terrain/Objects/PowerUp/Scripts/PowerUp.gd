extends Area2D

func _ready():
	$AnimationPlayer.play("Idle")


func _on_PowerUp_body_entered(body):
	if body.is_in_group("Player"):
		$AnimationPlayer.play("Hide")
		$AudioStreamPlayer.play()
		
		if not GLOBAL.powerful_shot:
			GLOBAL.powerful_shot = true
		else:
			GLOBAL.coins += 100


func _on_AudioStreamPlayer_finished():
	queue_free()
