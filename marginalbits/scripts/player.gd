extends CharacterBody2D

const SPEED := 130.0
const JUMP_VELOCITY := -300.0
const ATTACK_CONTROL := 40.0

var is_jumping := false
var is_attacking := false
var is_hurt := false
var is_dead := false
var attack_hold_vx := 0.0
var attack_has_hit := false  # <- evita hits múltiplos por ataque
var facing := 1

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var health: Node = $Health
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D

func _ready() -> void:
	health.died.connect(_on_died)
	health.damaged.connect(_on_damaged)
	animation.animation_finished.connect(_on_anim_finished)
	animation.frame_changed.connect(_on_frame_changed)

	# AttackArea inicialmente desligada
	attack_area.monitoring = false
	attack_area.monitorable = true
	attack_area.body_entered.connect(_on_attack_area_body_entered)

func _on_damaged(amount: int, from: Node) -> void:
	if is_dead or is_hurt: return
	is_hurt = true
	is_attacking = false
	if animation.animation != "hit":
		animation.play("hit")

func _on_died() -> void:
	if is_dead: return
	is_dead = true
	is_attacking = false
	is_hurt = false
	animation.play("die")
	set_physics_process(false)

func _on_anim_finished() -> void:
	match animation.animation:
		"hit":
			is_hurt = false
		"attack":
			is_attacking = false
			# garante que desliga a hitbox ao terminar
			attack_area.monitoring = false
			attack_has_hit = false
		"die":
			get_tree().reload_current_scene()

func _on_frame_changed() -> void:
	# ativa a hitbox só nos frames de impacto do ataque
	if animation.animation == "attack":
		# ajuste os frames conforme sua sprite (ex.: 1 e 2)
		var f := animation.frame
		var active := (f == 1 or f == 2)
		attack_area.monitoring = active and is_attacking and not is_dead and not is_hurt

		# posiciona a área à frente do personagem
		var offset := 12.0  # ajuste conforme o alcance do golpe
		attack_area.position.x = offset * facing
		attack_area.position.y = 0

	else:
		# fora da animação de ataque, sempre desligada
		attack_area.monitoring = false

func _on_attack_area_body_entered(body: Node) -> void:
	# só aplica uma vez por ataque
	if not is_attacking or attack_has_hit: return

	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(1, global_position)
			attack_has_hit = true  # evita múltiplos hits nesse mesmo swing

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not is_dead and not is_hurt:
		velocity.y = JUMP_VELOCITY
		is_jumping = true
	elif is_on_floor():
		is_jumping = false

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		facing = sign(direction)

	if Input.is_action_just_pressed("attack") and not is_attacking and not is_hurt and not is_dead:
		is_attacking = true
		attack_has_hit = false
		attack_hold_vx = velocity.x
		animation.play("attack")
		animation.frame = 0

	# Movimento
	if is_dead:
		velocity.x = 0
	elif is_attacking:
		var target := direction * SPEED
		velocity.x = move_toward(attack_hold_vx, target, ATTACK_CONTROL * delta)
		attack_hold_vx = velocity.x
	else:
		velocity.x = direction * SPEED

	# Animação (prioridade: die > hit > attack > locomotion)
	animation.scale.x = facing
	if not (is_dead or is_hurt or is_attacking):
		if direction != 0:
			if is_on_floor() and animation.animation != "run":
				animation.play("run")
			elif not is_on_floor() and animation.animation != "jump":
				animation.play("jump")
		elif is_jumping and animation.animation != "jump":
			animation.play("jump")
		elif is_on_floor() and animation.animation != "idle":
			animation.play("idle")

	move_and_slide()
