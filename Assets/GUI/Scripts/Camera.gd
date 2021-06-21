extends Camera2D

onready var player = get_tree().get_nodes_in_group("Player")[0] # Referencias al nodo player.

func _process(_delta) -> void:
	global_position.x = player.global_position.x
