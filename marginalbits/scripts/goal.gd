extends Area2D

@export var next_level: PackedScene

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if next_level:
			print("Entering level: " + next_level.resource_path)
			# Deferred scene change
			call_deferred("change_scene", next_level)
		else:
			push_warning("Goal node has no next_level assigned!")

# Helper function called deferred
func change_scene(scene: PackedScene) -> void:
	get_tree().change_scene_to_packed(scene)
