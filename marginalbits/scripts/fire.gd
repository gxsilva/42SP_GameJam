# Fire.gd
extends Area2D

@export var damage := 1
@export var tick := .1

var _bodies: Dictionary = {}  # body -> acumulador de tempo

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("players"):
		_bodies[body] = 0.0

func _on_body_exited(body: Node) -> void:
	_bodies.erase(body)

func _physics_process(delta: float) -> void:
	for body in _bodies.keys():
		if not is_instance_valid(body):
			_bodies.erase(body)
			continue
		_bodies[body] += delta
		while _bodies[body] >= tick:
			var health: Node = body.get_node_or_null("Health")  # << tipado
			if health:
				# Se tiver class_name Health, pode fazer:
				# (health as Health).take_damage(damage, self)
				health.call("take_damage", damage, self)
			_bodies[body] -= tick
