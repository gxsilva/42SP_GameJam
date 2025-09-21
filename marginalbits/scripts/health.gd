# Health.gd
extends Node
signal damaged(amount, from)
signal died()

@export var max_hp := 4
var hp := 0

func _ready() -> void:
	hp = max_hp

func take_damage(amount: int, from: Node = null) -> void:
	if hp <= 0:
		return
	hp -= amount
	emit_signal("damaged", amount, from)
	if hp <= 0:
		emit_signal("died")
