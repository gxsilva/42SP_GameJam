extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("you died")
		timer.start()

func _on_timer_timeout() -> void:
	print("reset")
	get_tree().reload_current_scene()
