extends Area2D

export(String, "Coin", "Chest") var type : String
onready var active : bool = true


func _ready() -> void:
	get_node("AnimationPlayer").play("Idle")


func _on_Coin_body_entered(body):
	if body.is_in_group("Player"):
		get_node("AnimationPlayer").play("Join")


func _on_AnimationPlayer_animation_started(anim_name):
	match anim_name:
		"Join":
			if active:
				get_node("AudioStreamPlayer").play()
				active = false
			
				match type:
					"Coin":
						GLOBAL.coins += 1
					"Chest":
						GLOBAL.coins += 100


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Join":
			queue_free()
