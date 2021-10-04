extends Area2D

var Shot : PackedScene = load("res://Assets/Characters/Player/Shot.tscn")

onready var player : KinematicBody2D = get_tree().get_nodes_in_group("Player")[0] # Referencias al nodo player.
var motion : float

func _ready():
	GLOBAL.powerful_shot = true # Cuando entra en pantalla powerful_shot es igual a true.
	global_position = Vector2(player.global_position.x, player.global_position.y - 8)
	$AnimatedSprite.play("Idle")


func _process(_delta) -> void:
	# Añado esta función para que todo esto suceda unicamente si player se encuentra en el árbol de escenas y evitar errores.
	if is_instance_valid(player):
		motion_ctrl()
		tween_ctrl()
		
		# Lo hago así en lugar de hacerlo en la función Input por economizar código.
		if Input.is_action_just_pressed("shot"):
			shot_ctrl()


func motion_ctrl() -> void:
	if player.get_node("Sprite").flip_h:
		scale.x = -1
		motion = player.global_position.x + 22
	else:
		scale.x = 1
		motion = player.global_position.x - 22


func tween_ctrl() -> void:
	$Tween.interpolate_property(
		self, # Objeto afectado.
		"global_position", # Propiedad afectada. 
		global_position, # Valor inicial.
		Vector2(motion, player.global_position.y - 8), # Valor final.
		0.2, # Tiempo que transcurre entre uno y otro.
		Tween.TRANS_SINE, # Transición inicial.
		Tween.EASE_OUT # Transición final.
	)
	$Tween.start()


func shot_ctrl():
	var shot = Shot.instance()
	shot.global_position = $ShotSpawn.global_position
	
	if player.get_node("Sprite").flip_h:
		shot.scale.x = -1
		shot.direction = -224
	else:
		shot.scale.x = 1
		shot.direction = 224
	
	get_tree().call_group("Level", "add_child", shot)


func _on_Spirit_tree_exited():
	GLOBAL.powerful_shot = false
