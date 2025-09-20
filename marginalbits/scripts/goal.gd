extends Area2D

@export var next_level: String = "res://scenes/Level1.tscn"

func _on_body_entered(body):
	if body.name == "Player":
		print("entrou")
		get_tree().change_scene_to_file(next_level)
