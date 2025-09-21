extends Node2D


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/forest.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
