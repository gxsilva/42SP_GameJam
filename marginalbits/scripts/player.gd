extends CharacterBody2D

const SPEED := 130.0
const JUMP_VELOCITY := -300.0

# Quanto de controle horizontal você tem enquanto ataca (0 = nenhum, SPEED = total)
const ATTACK_CONTROL := 40.0

var is_jumping := false
var is_attacking := false
var attack_hold_vx := 0.0   # armazena o momentum quando o ataque começa
var facing := 1              # 1 = direita, -1 = esquerda

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	# Gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true
	elif is_on_floor():
		is_jumping = false

	# Direção do input (sempre lemos, mesmo atacando)
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		facing = sign(direction)

	# Ataque: iniciar
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		attack_hold_vx = velocity.x   # guarda o embalo atual
		animation.play("attack")

	# Movimento horizontal
	if is_attacking:
		# Preserva o momentum e permite um pouco de controle
		var target := direction * SPEED
		# move_toward aproxima aos poucos; ajuste ATTACK_CONTROL p/ mais ou menos controle
		velocity.x = move_toward(attack_hold_vx, target, ATTACK_CONTROL * delta)
		attack_hold_vx = velocity.x  # mantém atualizado durante o ataque
	else:
		velocity.x = direction * SPEED

	# Animações (não mudamos enquanto ataca)
	if is_attacking:
		# Só espelhamos/viramos, sem trocar a animação de "attack"
		animation.scale.x = facing
	else:
		animation.scale.x = facing
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

func _on_animated_sprite_2d_animation_finished() -> void:
	if animation.animation == "attack":
		is_attacking = false
