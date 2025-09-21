extends CanvasLayer

@export var heart_texture: Texture2D
@export var max_health := 4

@onready var hearts := $HeartsContainer

@onready var player := $"../Player"  # adjust path
@onready var health := player.get_node("Health")

func _ready() -> void:
	# Create the hearts once
	for i in range(max_health):
		var heart = TextureRect.new()
		heart.texture = heart_texture
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart.custom_minimum_size = Vector2(16, 16)  # ensure visible
		hearts.add_child(heart)
		
	update_hearts(max_health)
	health.damaged.connect(_on_player_damaged)
	health.died.connect(_on_player_died)

func clear_hearts() -> void:
	for child in hearts.get_children():
		child.queue_free()

func update_hearts(current_health: int) -> void:
	for i in range(hearts.get_child_count()):
		var heart = hearts.get_child(i)
		heart.modulate = Color(1, 1, 1, 1) if i < current_health else Color(0.2, 0.2, 0.2, 0.5)
		
func _on_player_damaged(amount: int, from: Node) -> void:
	update_hearts(health.hp)

func _on_player_died() -> void:
	update_hearts(0)
