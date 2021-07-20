extends Node2D

func _ready():
	GLOBAL.coins = 0
	$MobilePlatform/AnimationPlayer.play("Move")
