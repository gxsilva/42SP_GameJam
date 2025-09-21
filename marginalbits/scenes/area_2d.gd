extends Area2D

@export var dialog_text: Array[String] = []
@export var offset_position: Vector2 = Vector2(0, -120)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
			DialogManeger.start_dialog(dialog_text, global_position + offset_position)
