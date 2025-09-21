extends CharacterBody2D

@export var speed: float = 50.0
@export var patrol_distance: float = 50.0
@export var attack_range: float = 50.0
@export var attack_damage: int = 1
@export var max_health: int = 2
@export var knockback_force: float = 200.0
@export var hit_flash_time: float = 0.2

# NOVOS: cooldown do ataque e atraso do primeiro hit (opcional)
@export var attack_cooldown: float = 2.0
@export var first_attack_delay: float = 0.25

var left_limit: float
var right_limit: float
var patrol_direction: int = 1

var chasing: bool = false
var player_ref: Node2D = null
var current_health: int
var hit_timer: float = 0

# Agora guardamos o cooldown restante por alvo (body -> cooldown_restante)
var _targets_cd: Dictionary = {} 

@onready var anim = $AnimatedSprite2D

func _ready():
	left_limit = global_position.x - patrol_distance
	right_limit = global_position.x + patrol_distance
	current_health = max_health

func _physics_process(delta):
	# ===== Flash de dano =====
	if hit_timer > 0.0:
		hit_timer -= delta
		anim.modulate = Color(1, 0, 0)
	else:
		anim.modulate = Color(1, 1, 1)

	# Se estiver em "hit stun", não mover
	if hit_timer > 0.0:
		move_and_slide()
		return

	# ===== ATAQUE COM COOLDOWN POR ALVO =====
	# Para cada corpo rastreado, contamos o cooldown e aplicamos dano quando possível
	for body in _targets_cd.keys():
		if not is_instance_valid(body):
			_targets_cd.erase(body)
			continue

		_targets_cd[body] = max(0.0, float(_targets_cd[body]) - delta)

		# Só ataca se estiver dentro do alcance
		if body is Node2D:
			var dist := global_position.distance_to((body as Node2D).global_position)
			if dist <= attack_range and _targets_cd[body] <= 0.0:
				var health: Node = body.get_node_or_null("Health")
				if health:
					health.take_damage(attack_damage, self)
				_targets_cd[body] = attack_cooldown

	# ===== MOVIMENTO: PERSEGUIR OU PATRULHAR =====
	if chasing and player_ref:
		var distance = global_position.distance_to(player_ref.global_position)
		if distance > attack_range:
			# mover em direção ao player
			var direction = (player_ref.global_position - global_position).normalized()
			velocity = direction * speed
			if velocity.x > 0:
				anim.play("run_right")
			elif velocity.x < 0:
				anim.play("run_left")
		else:
			# parar no lugar ao entrar no alcance de ataque (animação de ataque)
			velocity = Vector2.ZERO
			if player_ref.global_position.x > global_position.x:
				anim.play("attack_right")
			else:
				anim.play("attack_left")
	else:
		# patrulha
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

	move_and_slide()

func take_damage(amount: int, source_pos: Vector2) -> void:
	current_health -= amount
	print("Enemy takes %d damage! Current health: %d" % [amount, current_health])

	# flash de hit
	hit_timer = hit_flash_time

	# knockback
	var knockback_dir = (global_position - source_pos).normalized()
	velocity = knockback_dir * knockback_force
	
	if current_health <= 0:
		die()

func die() -> void:
	print("Enemy died!")

	# trava movimento e ataques
	set_physics_process(false)
	velocity = Vector2.ZERO
	chasing = false

	# toca animação certa
	if player_ref and player_ref.global_position.x > global_position.x:
		anim.play("death_right")
	else:
		anim.play("death_left")
	$CollisionShape2D.set_deferred("disabled", true)

	# quando animação acabar → remover inimigo
	#anim.animation_finished.connect(_on_death_anim_finished, CONNECT_ONESHOT)

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# inicia com um pequeno atraso para não dar hit instantâneo
		_targets_cd[body] = first_attack_delay
		chasing = true
		player_ref = body
		print("Player detected!")

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body in _targets_cd:
		_targets_cd.erase(body)
	if body == player_ref:
		chasing = false
		player_ref = null
		print("Player lost!")
