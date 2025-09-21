extends CharacterBody2D

@export var speed: float = 50.0
@export var patrol_distance: float = 50.0
@export var attack_range: float = 50.0
@export var attack_damage: int = 10
@export var attack_cooldown: float = 1.0
@export var max_health: int = 100
@export var knockback_force: float = 200.0
@export var hit_flash_time: float = 0.2

var left_limit: float
var right_limit: float
var patrol_direction: int = 1

var chasing: bool = false
var player_ref: Node = null
var attacking: bool = false
var attack_timer: float = 0.0
var current_health: int
var hit_timer: float = 0.0

@onready var anim = $AnimatedSprite2D

func _ready():
	left_limit = global_position.x - patrol_distance
	right_limit = global_position.x + patrol_distance
	current_health = max_health

func _physics_process(delta):
	# Countdown attack timer
	if attack_timer > 0.0:
		attack_timer -= delta
	else:
		attacking = false

	# Countdown hit flash timer
	if hit_timer > 0.0:
		hit_timer -= delta
		anim.modulate = Color(1, 0, 0)  # red flash
	else:
		anim.modulate = Color(1, 1, 1)  # normal color

	# Skip normal movement if being hit (knockback)
	if hit_timer > 0.0:
		move_and_slide()  # Godot 4: no arguments
		return

	if chasing and player_ref:
		var distance = global_position.distance_to(player_ref.global_position)

		if distance <= attack_range:
			if not attacking:
				attacking = true
				velocity = Vector2.ZERO  # stop movement during attack
				if player_ref.global_position.x > global_position.x:
					anim.play("attack_right")
				else:
					anim.play("attack_left")
				print("Enemy attacks for %d damage!" % attack_damage)
				attack_timer = attack_cooldown
		else:
			attacking = false
			var direction = (player_ref.global_position - global_position).normalized()
			velocity = direction * 80
			if velocity.x > 0:
				anim.play("run_right")
			elif velocity.x < 0:
				anim.play("run_left")
	else:
		if not attacking:
			velocity.x = patrol_direction * speed
			velocity.y = 0

			if patrol_direction > 0:
				anim.play("walk_right")
			else:
				anim.play("walk_left")

			if global_position.x > right_limit:
				patrol_direction = -1
			elif global_position.x < left_limit:
				patrol_direction = 1

	move_and_slide()  # Godot 4: no arguments

func take_damage(amount: int, source_pos: Vector2) -> void:
	current_health -= amount
	print("Enemy takes %d damage! Current health: %d" % [amount, current_health])

	# Start hit flash
	hit_timer = hit_flash_time

	# Apply knockback away from the attacker
	var knockback_dir = (global_position - source_pos).normalized()
	velocity = knockback_dir * knockback_force

	if current_health <= 0:
		die()

func die() -> void:
	print("Enemy died!")
	queue_free()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		chasing = true
		player_ref = body
		print("Player detected!")

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player_ref:
		chasing = false
		player_ref = null
		attacking = false
		attack_timer = 0.0
		print("Player lost!")
