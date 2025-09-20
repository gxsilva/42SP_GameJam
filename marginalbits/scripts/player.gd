extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0

var is_jumping := false
var is_attacking := false
@onready var animation = $AnimatedSprite2D as AnimatedSprite2D

func _ready():
	animation.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true
	elif is_on_floor():
		is_jumping = false

	# Attack
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		animation.play("attack")

	# Stop movement/animation during attack
	if is_attacking:
		velocity.x = 0
		move_and_slide()
		return  # skip movement/animation updates

	# Movement
	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * SPEED
	if direction != 0:
		animation.scale.x = direction
		if is_on_floor() and animation.animation != "run":
			animation.play("run")
		elif not is_on_floor() and animation.animation != "jump":
			animation.play("jump")
	elif is_jumping and animation.animation != "jump":
		animation.play("jump")
	elif is_on_floor() and animation.animation != "idle":
		animation.play("idle")

	move_and_slide()

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "attack":
		is_attacking = false
