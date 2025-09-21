extends CharacterBody2D

class_name Player

const SPEED := 130.0
const JUMP_VELOCITY := -300.0
const ATTACK_CONTROL := 40.0

var is_jumping := false
var is_attacking := false
var is_hurt := false
var is_dead := false
var attack_hold_vx := 0.0
var facing := 1

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var health: Node = $Health

func _ready() -> void:
	health.died.connect(_on_died)
	health.damaged.connect(_on_damaged)
	# Conecta UMA vez
	animation.animation_finished.connect(_on_anim_finished)

func _on_damaged(amount: int, from: Node) -> void:
	if is_dead:
		return
	# Já está em hit? então não reinicia
	if is_hurt:
		return
	is_hurt = true
	is_attacking = false
	if animation.animation != "hit":
		animation.play("hit")
	# não mexa em animation.frame aqui


func _on_died() -> void:
	if is_dead:
		return
	is_dead = true
	is_attacking = false
	is_hurt = false
	animation.play("die")
	set_physics_process(false)  # trava controles

func _on_anim_finished() -> void:
	match animation.animation:
		"hit":
			is_hurt = false
		"attack":
			is_attacking = false
		"die":
			get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("jump")) and is_on_floor() and not is_dead and not is_hurt:
		velocity.y = JUMP_VELOCITY
		is_jumping = true
	elif is_on_floor():
		is_jumping = false

	var direction := Input.get_axis("move_left", "move_rigth")
	if direction != 0:
		facing = sign(direction)

	# Ataque só se não estiver hurt/dead
	if Input.is_action_just_pressed("attack") and not is_attacking and not is_hurt and not is_dead:
		is_attacking = true
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
