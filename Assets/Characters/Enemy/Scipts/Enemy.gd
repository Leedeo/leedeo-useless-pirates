extends KinematicBody2D

export(int, 1, 10) var health : int = 3

func _ready() -> void:
	$AnimatedSprite.play("Idle")


func _process(_delta) -> void:
	if health <= 0:
		queue_free()


func damage_ctrl(damage) -> void:
	# Vamos a solicitar un parámetro para poder definir la cantidad de vida que se elimina.
	health -= damage
	print("La vida del enemigo es igual a: " + str(health))
