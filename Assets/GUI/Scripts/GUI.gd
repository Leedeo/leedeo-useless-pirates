extends CanvasLayer

func _process(_delta):
	$HBoxContainer/Label.text = str("x ") + str(GLOBAL.coins)
