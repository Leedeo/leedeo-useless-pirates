extends Node2D

func _ready():
	GLOBAL.coins = 0
	get_node("MobilePlatform/AnimationPlayer").play("Move")
